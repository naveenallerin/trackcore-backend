module Api
  module V1
    class ApprovalsController < ApplicationController
      before_action :set_approval_request
      rescue_from ApprovalError::InvalidStep, 
                  ApprovalError::UnauthorizedApprover,
                  ApprovalError::InvalidWorkflowState,
                  with: :render_approval_error
      rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      # PATCH /api/v1/approvals/:approval_request_id/steps/:step_id/approve
      def approve_step
        workflow_service = ApprovalWorkflowService.new(@approval_request)
        workflow_service.approve_step(
          step_id: params[:step_id],
          approver_id: approval_params[:approver_id],
          comment: approval_params[:comment]
        )

        render_approval_response
      end

      # PATCH /api/v1/approvals/:approval_request_id/steps/:step_id/reject
      def reject_step
        workflow_service = ApprovalWorkflowService.new(@approval_request)
        workflow_service.reject_step(
          step_id: params[:step_id],
          approver_id: approval_params[:approver_id],
          reason: approval_params[:reason]
        )

        render_approval_response
      end

      # PATCH /api/v1/approvals/:approval_request_id/complete
      def complete
        workflow_service = ApprovalWorkflowService.new(@approval_request)
        workflow_service.complete

        render_approval_response
      end

      private

      def set_approval_request
        @approval_request = ApprovalRequest.find(params[:approval_request_id])
      end

      def approval_params
        params.require(:approval).permit(:approver_id, :reason, :comment)
      end

      def render_approval_response
        render json: {
          status: @approval_request.status,
          steps: format_steps(@approval_request.approval_steps)
        }, status: :ok
      end

      def format_steps(steps)
        steps.map do |step|
          {
            id: step.id,
            name: step.step_name,
            status: step.status,
            order_index: step.order_index,
            approver_id: step.approver_id,
            approved_at: step.try(:approved_at),
            rejected_at: step.try(:rejected_at),
            comment: step.comment
          }
        end
      end

      def render_approval_error(exception)
        render json: { 
          error: exception.message 
        }, status: :unprocessable_entity
      end

      def render_validation_error(exception)
        render json: { 
          error: exception.record.errors.full_messages.join(", ") 
        }, status: :bad_request
      end

      def render_not_found(exception)
        render json: { 
          error: "Resource not found" 
        }, status: :not_found
      end
    end
  end
end
