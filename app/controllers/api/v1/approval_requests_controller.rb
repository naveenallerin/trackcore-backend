module Api
  module V1
    class ApprovalRequestsController < ApplicationController
      include ApiVersioning
      include RateLimiting

      before_action :authenticate_user!
      before_action :set_approval_request, only: [:update]
      
      def create
        @requisition = Requisition.find(params[:requisition_id])
        authorize @requisition, :create_approval?
        
        @approval_request = ApprovalService.create_approval_request(@requisition, current_user)
        render json: ApprovalRequestSerializer.new(@approval_request).serialized_json, status: :created
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Requisition not found' }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def update
        authorize @approval_request
        
        if ApprovalService.process_approval(@approval_request, approval_params[:status], approval_params[:comments])
          render json: ApprovalRequestSerializer.new(@approval_request).serialized_json, status: :ok
        else
          render json: { error: 'Failed to process approval' }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_approval_request
        @approval_request = ApprovalRequest.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Approval request not found' }, status: :not_found
      end

      def approval_params
        params.require(:approval_request).permit(:status, :comments)
      end
    end
  end
end
