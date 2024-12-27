module Api
  module V1
    class ApprovalRequestsController < ApplicationController
      def create
        @requisition = Requisition.find(params[:requisition_id])
        @approval_request = ApprovalService.create_approval_request(@requisition, current_user)
        render json: @approval_request, status: :created
      end
      
      def update
        @approval_request = ApprovalRequest.find(params[:id])
        ApprovalService.process_approval(@approval_request, params[:status], params[:comments])
        render json: @approval_request
      end
    end
  end
end
