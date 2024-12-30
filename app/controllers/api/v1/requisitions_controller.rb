module Api
  module V1
    class RequisitionsController < ApplicationController
      before_action :set_requisition, only: [:show, :update, :destroy, :request_approval, :approval_status, :approval_complete, :clone]
      
      def index
        @requisitions = Requisition.all
        render json: @requisitions
      end
      
      def show
        render json: @requisition
      end
      
      def create
        @requisition = current_user.requisitions.build(requisition_params)
        apply_template_if_present
        
        if @requisition.save
          render json: @requisition, status: :created
        else
          render json: @requisition.errors, status: :unprocessable_entity
        end
      end

      def update
        apply_template_if_present
        if @requisition.update(requisition_params)
          render json: @requisition, status: :ok
        else
          render json: @requisition.errors, status: :unprocessable_entity
        end
      end

      def request_approval
        service = ApprovalService.new(@requisition)
        approval = service.request_approval(approver_type: params[:approver_type])
        render json: approval, status: :created
      rescue ApprovalService::ApprovalError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def approval_status
        render json: { status: @requisition.approval_status }
      end

      def approval_complete
        approval = @requisition.approval_requests.find(params[:approval_id])
        approval.update!(status: params[:status])
        render json: { status: :ok }
      end

      def clone
        requisition = Requisition.find(params[:id])
        cloned_requisition = CloneRequisitionService.clone(requisition)
        render json: cloned_requisition, status: :created
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Requisition not found' }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def bulk_create
        results = BulkCreateRequisitionsService.create(bulk_params, current_user)
        render json: results, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      private
      
      def set_requisition
        @requisition = Requisition.find(params[:id])
      end
      
      def requisition_params
        params.require(:requisition).permit(
          :title, :department_id, :salary_range, :location,
          :description, :status, :template_id, requisition_fields_attributes: [:id, :field_name, :field_type, :field_value]
        )
      end

      def bulk_params
        params.require(:requisitions).map do |req|
          req.permit(:title, :description, :status, :post_to_boards)
        end
      end

      def apply_template_if_present
        if params[:template_id].present?
          template = Template.find(params[:template_id])
          placeholders = extract_placeholders_from_params
          @requisition.description = TemplateRendererService.render_content(
            template.body, 
            placeholders
          )
        end
      rescue ActiveRecord::RecordNotFound
        @requisition.errors.add(:template_id, "Template not found")
      end

      def extract_placeholders_from_params
        params[:placeholders]&.to_unsafe_h || {}
      end
    end
  end
end
