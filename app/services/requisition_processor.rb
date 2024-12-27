class RequisitionProcessor
  def initialize(requisition)
    @requisition = requisition
  end
  
  def submit_for_approval
    return false unless @requisition.draft?
    
    ApplicationRecord.transaction do
      @requisition.update!(status: :pending_approval)
      create_approval_request
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  def setup_approval_workflow(approvers)
    return false if approvers.empty?
    
    ApplicationRecord.transaction do
      approvers.each_with_index do |approver, index|
        @requisition.approval_steps.create!(
          approver: approver,
          sequence: index + 1,
          status: index.zero? ? :pending : :waiting
        )
      end
    end
    
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  def process_approval(approver)
    step = @requisition.approval_steps.find_by(approver: approver, status: :pending)
    return false unless step
    
    ApplicationRecord.transaction do
      step.update!(status: :approved)
      update_requisition_status
    end
    
    true
  end
  
  private
  
  def create_approval_request
    approval_id = ApprovalService.request_approval(@requisition)
    
    @requisition.update!(
      status: :pending_approval,
      approval_request_id: approval_id
    )
  rescue => e
    Rails.logger.error "Failed to create approval request: #{e.message}"
    raise ActiveRecord::RecordInvalid
  end
  
  def update_requisition_status
    if @requisition.approval_steps.pending.none?
      @requisition.update!(status: :approved)
    end
  end
end
