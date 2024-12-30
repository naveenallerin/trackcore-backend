module ApprovalError
  class InvalidStep < StandardError; end
  class UnauthorizedApprover < StandardError; end
  class InvalidWorkflowState < StandardError; end
end

class ApprovalWorkflowService
  attr_reader :approval_request

  # @param approval_request [ApprovalRequest, Integer] The approval request or its ID
  # @raise [ActiveRecord::RecordNotFound] If approval request doesn't exist
  def initialize(approval_request)
    @approval_request = approval_request.is_a?(ApprovalRequest) ? 
      approval_request : ApprovalRequest.find(approval_request)
  end

  # Approves a specific step in the approval workflow
  # @param step_id [Integer] The ID of the step to approve
  # @param approver_id [String] The ID of the approver
  # @param comment [String] Optional comment for the approval
  # @raise [ApprovalError::InvalidStep] If step is invalid or out of sequence
  # @raise [ApprovalError::UnauthorizedApprover] If approver is not authorized
  def approve_step(step_id:, approver_id:, comment: nil)
    ActiveRecord::Base.transaction do
      step = validate_step!(step_id, approver_id)
      
      step.update!(
        status: :approved,
        approved_at: Time.current,
        comment: comment
      )

      if final_step?(step)
        approval_request.approve!(comment)
        update_requisition_status(:approved) if approval_request.approvable.is_a?(Requisition)
        notify_approval_complete
      elsif next_step = approval_request.next_step(step)
        next_step.update!(status: :pending)
      end
    end
  end

  # Rejects a specific step in the approval workflow
  # @param step_id [Integer] The ID of the step to reject
  # @param approver_id [String] The ID of the approver
  # @param reason [String] Required reason for rejection
  # @raise [ApprovalError::InvalidStep] If step is invalid or out of sequence
  # @raise [ApprovalError::UnauthorizedApprover] If approver is not authorized
  def reject_step(step_id:, approver_id:, reason:)
    raise ArgumentError, "Reason is required for rejection" if reason.blank?

    ActiveRecord::Base.transaction do
      step = validate_step!(step_id, approver_id)
      
      step.update!(
        status: :rejected,
        rejected_at: Time.current,
        comment: reason
      )

      approval_request.reject!(reason)
    end
  end

  private

  def validate_step!(step_id, approver_id)
    step = approval_request.approval_steps.find_by(id: step_id)
    
    raise ApprovalError::InvalidStep, "Step not found" unless step
    raise ApprovalError::InvalidStep, "Step is not pending" unless step.pending?
    raise ApprovalError::InvalidStep, "Previous steps are not all approved" unless previous_steps_approved?(step)
    raise ApprovalError::UnauthorizedApprover, "Invalid approver" unless valid_approver?(step, approver_id)
    
    step
  end

  def previous_steps_approved?(step)
    approval_request.approval_steps
                   .where("order_index < ?", step.order_index)
                   .all?(&:approved?)
  end

  def final_step?(step)
    approval_request.approval_steps
                   .where("order_index > ?", step.order_index)
                   .none?
  end

  def valid_approver?(step, approver_id)
    step.approver_id == approver_id
  end

  def update_requisition_status(status)
    requisition = approval_request.approvable
    requisition.update!(status: status)
  end

  def notify_approval_complete
    # Example: Notify external service or publish event
    # ApprovalEvents.publish('approval_request.completed', 
    #   request_id: approval_request.id,
    #   status: approval_request.status
    # )
  end
end
