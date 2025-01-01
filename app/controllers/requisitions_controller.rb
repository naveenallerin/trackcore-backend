class RequisitionsController < ApplicationController
  before_action :set_requisition, only: [:show, :update, :destroy, :clone, :post_to_boards, :ai_generate_description, :initiate_approval_flow]
  after_action :verify_authorized, except: [:index]

  def index
    @requisitions = policy_scope(Requisition)
    render json: @requisitions
  end

  def show
    authorize @requisition
    render json: @requisition
  end

  def create
    @requisition = current_user.requisitions.build(requisition_params)
    authorize @requisition

    if @requisition.save
      render json: @requisition, status: :created
    else
      render json: @requisition.errors, status: :unprocessable_entity
    end
  end

  def clone
    authorize @requisition, :clone?
    new_requisition = @requisition.clone_with_associations(current_user)

    if new_requisition.save
      render json: new_requisition, status: :created
    else
      render json: { error: "Failed to clone requisition", details: new_requisition.errors }, 
             status: :unprocessable_entity
    end
  end

  def bulk_create
    authorize Requisition, :bulk_create?
    
    result = RequisitionBulkCreateService.new(
      requisitions_params: bulk_params,
      user: current_user
    ).execute

    if result.success?
      render json: result.requisitions, status: :created
    else
      render json: { error: "Bulk creation failed", details: result.errors },
             status: :unprocessable_entity
    end
  end

  def update
    authorize @requisition
    
    if requires_cfo_approval? && !current_user.cfo?
      render json: { 
        error: "CFO approval required for requisitions with salary > $150,000" 
      }, status: :forbidden
      return
    end

    if @requisition.update(requisition_params)
      render json: @requisition
    else
      render json: { error: "Update failed", details: @requisition.errors },
             status: :unprocessable_entity
    end
  end

  def post_to_boards
    @requisition = Requisition.find(params[:id])
    service = JobBoardIntegrationService.new
    
    results = {
      indeed: service.post_to_indeed(@requisition),
      linkedin: service.post_to_linkedin(@requisition),
      glassdoor: service.post_to_glassdoor(@requisition)
    }

    logs = JobBoardLog.where(requisition_id: @requisition.id)
                     .order(created_at: :desc)
                     .limit(3)

    render json: {
      success: results.values.any?(true),
      results: results,
      logs: logs
    }
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: 'Requisition not found' }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def ai_generate_description
    @requisition = Requisition.find(params[:id])
    service = AiDescriptionService.new

    result = service.generate_description(
      title: @requisition.title,
      current_description: @requisition.description,
      requirements: @requisition.requirements
    )

    if @requisition.update(description: result)
      render json: { 
        success: true, 
        description: @requisition.description 
      }
    else
      render json: { 
        success: false, 
        errors: @requisition.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: 'Requisition not found' }, status: :not_found
  rescue AiDescriptionService::AiError => e
    render json: { error: e.message }, status: :service_unavailable
  end

  def initiate_approval_flow
    @requisition = Requisition.find(params[:id])
    authorize @requisition, :initiate_approval?

    if @requisition.approval_requests.any?
      render_error("Approval flow already initiated", :unprocessable_entity)
      return
    end

    begin
      approval_requests = AdaptiveApprovalService.create_approval_requests_for(@requisition)
      @requisition.update!(status: 'pending_approval')
      
      render json: approval_requests, status: :created
    rescue ArgumentError => e
      render_error(e.message, :unprocessable_entity)
    end
  end

  private

  def set_requisition
    @requisition = Requisition.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Requisition not found' }, status: :not_found
  end

  def requisition_params
    params.require(:requisition).permit(
      :title, :department, :salary, :status, :cfo_approved, :seasonal,
      # Add other permitted attributes here
    )
  end

  def requires_cfo_approval?
    requisition_params[:status] == "approved" && 
      @requisition.salary.to_i > 150000 && 
      !@requisition.cfo_approved?
  end

  def bulk_params
    params.require(:requisitions).map do |req_params|
      req_params.permit(:title, :department_id, :salary, :description, :seasonal)
    end
  end

  def render_error(message, status)
    render json: { error: message }, status: status
  end
end
