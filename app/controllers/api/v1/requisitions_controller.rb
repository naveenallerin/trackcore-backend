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
        if @requisition.save
          render json: @requisition, status: :created
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
        cloned = RequisitionCloneService.new(@requisition).clone
        render json: cloned, status: :created
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
          :description, :status, requisition_fields_attributes: [:id, :field_name, :field_type, :field_value]
        )
      end
    end
  end
end
