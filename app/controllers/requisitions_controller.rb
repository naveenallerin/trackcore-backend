class RequisitionsController < ApplicationController
  before_action :set_requisition, only: [:show, :update, :destroy]

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

  private

  def set_requisition
    @requisition = Requisition.find(params[:id])
  end

  def requisition_params
    params.require(:requisition).permit(:title, :description, :status)
  end
end
