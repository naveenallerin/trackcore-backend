class ApprovalEscalationJob
  include Sidekiq::Job

  sidekiq_options queue: :escalations, retry: 3

  ROLE_HIERARCHY = {
    'finance_manager' => 'finance_director',
    'hr_manager' => 'hr_director',
    'finance_director' => 'cfo',
    'hr_director' => 'coo',
    'cfo' => 'ceo',
    'coo' => 'ceo',
    'ceo' => nil
  }.freeze

  def perform
    overdue_requests.find_each do |request|
      escalate_request(request)
    rescue StandardError => e
      Rails.logger.error("Failed to escalate ApprovalRequest #{request.id}: #{e.message}")
      raise e
    end
  end

  private

  def overdue_requests
    ApprovalRequest.where(status: 'pending')
                   .where('due_at < ?', Time.current)
  end

  def escalate_request(request)
    ActiveRecord::Base.transaction do
      next_approver = ROLE_HIERARCHY[request.approver_role]

      if next_approver
        create_escalated_request(request, next_approver)
        request.update!(
          status: 'escalated',
          escalated_at: Time.current,
          notes: "Automatically escalated to #{next_approver} due to no response by due date"
        )
      else
        notify_final_escalation(request)
        request.update!(
          status: 'expired',
          escalated_at: Time.current,
          notes: 'Maximum escalation level reached - marked as expired'
        )
      end

      log_escalation(request, next_approver)
    end
  end

  def create_escalated_request(original_request, next_approver)
    ApprovalRequest.create!(
      requisition: original_request.requisition,
      approver_role: next_approver,
      status: 'pending',
      due_at: 3.business_days.from_now.end_of_day,
      created_by: original_request.created_by,
      previous_request_id: original_request.id
    )
  end

  def notify_final_escalation(request)
    NotificationService.notify_admin(
      subject: 'Maximum Escalation Level Reached',
      message: "Requisition ##{request.requisition_id} has reached maximum escalation level",
      request_id: request.id
    )
  end

  def log_escalation(request, next_approver)
    AuditLog.create!(
      auditable: request,
      action: 'escalated',
      changes: {
        from_role: request.approver_role,
        to_role: next_approver,
        original_due_date: request.due_at
      }
    )
  end
end
