class RequisitionsController < ApplicationController
  before_action :set_requisition, only: [:show, :update, :destroy, :clone, :approve]

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
    new_requisition = @requisition.clone_requisition

    if new_requisition.save
      render json: new_requisition, status: :created
    else
      render json: { errors: new_requisition.errors }, status: :unprocessable_entity
    end
  end

  def update
    if requisition_params[:cfo_approved] && !current_user.cfo?
      render json: { error: "Only CFO can approve high-salary requisitions" }, status: :forbidden
      return
    end

    if @requisition.update(requisition_params)
      render json: @requisition
    else
      render json: { errors: @requisition.errors }, status: :unprocessable_entity
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
      :title, :department, :salary, :status, :cfo_approved,
      # Add other permitted attributes here
    )
  end
end
