module Api
  module V1
    class RequisitionsController < ApplicationController
      before_action :set_requisition, only: [:show, :update, :destroy]
      
      def index
        @requisitions = Requisition.all
        render json: @requisitions
      end
      
      def show
        render json: @requisition
      end
      
      def create
        @requisition = current_user.requisitions.build(requisition_params)
        if @requisition.save
          render json: @requisition, status: :created
        else
          render json: @requisition.errors, status: :unprocessable_entity
        end
      end

      def approval_complete
        @requisition = Requisition.find(params[:id])
        approval_status = params[:status]
        
        ApprovalService.new(@requisition).update_status(approval_status)
        
        render json: { status: 'success', requisition: @requisition }
      rescue ApprovalService::ApprovalError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      private
      
      def set_requisition
        @requisition = Requisition.find(params[:id])
      end
      
      def requisition_params
        params.require(:requisition).permit(:title, :description)
      end
    end
  end
end
