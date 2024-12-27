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
    approval_id = if external_approval_enabled?
      request_external_approval
    else
      create_internal_approval
    end
    
    @requisition.update!(
      status: :pending_approval,
      approval_request_id: approval_id,
      approval_service: external_approval_enabled? ? 'external' : 'internal'
    )
  rescue => e
    Rails.logger.error "Failed to create approval request: #{e.message}"
    EventPublisher.publish('approval.request.failed', {
      requisition_id: @requisition.id,
      error: e.message
    })
    raise ActiveRecord::RecordInvalid
  end

  def external_approval_enabled?
    Rails.configuration.x.approval_service.enabled
  end

  def request_external_approval
    response = ExternalApprovalService.request_approval(@requisition)
    EventPublisher.publish('external_approval.requested', 
      requisition_id: @requisition.id,
      external_id: response
    )
    response
  end
  
  def create_internal_approval
    approval = @requisition.create_approval_request!(
      status: :pending,
      department: @requisition.department
    )
    EventPublisher.publish('internal_approval.created', 
      requisition_id: @requisition.id,
      approval_id: approval.id
    )
    approval.id
  end
  
  def update_requisition_status
    if @requisition.approval_steps.pending.none?
      @requisition.update!(status: :approved)
    end
  end
end
