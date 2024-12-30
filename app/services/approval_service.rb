class ApprovalService
  class ApprovalError < StandardError; end
  class Error < StandardError; end

  
  def initialize(requisition, options = {})
    @requisition = requisition
    @external_service = options[:external_service]
    @internal_service = options[:internal_service]
    @external_adapter = options[:external_adapter] || ExternalApprovalAdapter.new
  end

  def request
    raise ApprovalError, 'Requisition already has an approval request' if @requisition.approval_request.present?
    
    @requisition.create_approval_request!(
      status: 'pending',
      metadata: { requested_at: Time.current }
    )
  rescue ActiveRecord::RecordInvalid => e
    raise ApprovalError, "Failed to create approval request: #{e.message}"
  end
  
  def update_status(status)
    raise ApprovalError, 'Invalid status' unless %w[approved rejected].include?(status)
    
    approval_request = @requisition.approval_request
    raise ApprovalError, 'No approval request found' unless approval_request

    approval_request.update!(status: status)
  rescue ActiveRecord::RecordInvalid => e
    raise ApprovalError, "Failed to update status: #{e.message}"
  end

  def request_approval(approver_type:)
    return handle_internal_approval if approver_type == 'internal'
    handle_external_approval
  end

  def check_status
    return check_external_status if external_approval?
    check_internal_status
  end

  def self.request_approval(requisition, approver)
    ApprovalRequest.create!(
      requisition: requisition,
      approver: approver,
      status: :pending
    )
  end

  def self.process_approval(approval_request, approved)
    approval_request.update!(status: approved ? :approved : :rejected)
    # Emit event or callback
    notify_requisition_service(approval_request)
  end

  def self.create_approval_request(requisition, approver)
    ApprovalRequest.create!(
      requisition: requisition,
      approver: approver,
      status: 'pending'
    )
  end
  
  def self.process_approval(approval_request, status, comments = nil)
    ActiveRecord::Base.transaction do
      approval_request.update!(
        status: status,
        comments: comments
      )
    end
  end

  def self.initiate_approval(requisition)
    # Add approval initiation logic
    true
  end

  def self.create_approval_request(requisition)
    ApprovalRequest.create!(requisition: requisition, status: 'pending')
  end

  def self.process_approval(approval_request, approved:)
    approval_request.update!(status: approved ? 'approved' : 'rejected')
  end

  def request_approval(requisition)
    # External approval service integration
    response = HTTParty.post(ENV['APPROVAL_SERVICE_URL'], 
      body: { requisition_id: requisition.id }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    
    raise Error, 'Failed to create approval request' unless response.success?
    response.parsed_response['request_id']
  end
  
  def check_status(request_id)
    response = HTTParty.get("#{ENV['APPROVAL_SERVICE_URL']}/#{request_id}")
    raise Error, 'Failed to check approval status' unless response.success?
    response.parsed_response['status']
  end

  private

  def external_approval?
    Rails.configuration.use_external_approval_service
  end

  def request_external_approval
    response = @external_adapter.create_approval_request(@requisition)
    
    @requisition.update!(
      external_approval_id: response['approval_id'],
      status: :pending_approval
    )
  end

  def request_internal_approval
    ActiveRecord::Base.transaction do
      approval_request = @requisition.create_approval_request!(
        status: :pending,
        approver: determine_approver
      )
      @requisition.update!(status: :pending_approval)
      
      ApprovalRequestedJob.perform_later(@requisition.id)
      approval_request
    end
  end

  def internal_approval(approver_type)
    @requisition.approval_requests.create!(
      approver_type: approver_type,
      status: 'pending'
    )
  end

  def external_approval(approver_type)
    # Initialize external approval request
    approval = @requisition.approval_requests.create!(
      approver_type: approver_type,
      status: 'pending'
    )
    
    # Here you would integrate with external approval system
    # Example: ExternalApprovalAPI.request_approval(approval)
    
    approval
  end

  def check_external_status
    return unless @requisition.external_approval_id
    
    response = @external_adapter.check_status(@requisition.external_approval_id)
    update_requisition_status(response['status'])
  end

  def check_internal_status
    @requisition.approval_request&.status
  end

  def determine_approver
    # Logic to determine the appropriate approver
    User.find_by(role: 'approver')
  end

  def update_requisition_status(status)
    mapped_status = map_external_status(status)
    @requisition.update!(status: mapped_status)
  end

  def map_external_status(external_status)
    {
      'APPROVED' => :approved,
      'REJECTED' => :rejected,
      'PENDING' => :pending_approval
    }[external_status.upcase] || :pending_approval
  end

  def self.notify_requisition_service(approval_request)
    # This could be replaced with an API call or event emission
    requisition = approval_request.requisition
    requisition.update!(approved_at: Time.current) if approval_request.approved?
  end

  def handle_internal_approval
    ActiveRecord::Base.transaction do
      approval_request = @requisition.approval_requests.create!(
        status: 'pending',
        approver_type: 'internal',
        metadata: { requested_at: Time.current }
      )
      notify_approvers(approval_request)
      approval_request
    end
  end

  def handle_external_approval
    # ...existing external approval code...
  end

  def notify_approvers(approval_request)
    # Add notification logic here
  end
end
