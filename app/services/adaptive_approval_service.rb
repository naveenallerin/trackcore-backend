require 'active_support/core_ext/time/calculations'

class AdaptiveApprovalService
  APPROVAL_DUE_DAYS = 3
  SALARY_THRESHOLD = 150_000

  def self.create_approval_requests_for(requisition)
    new.create_approval_requests_for(requisition)
  end

  def create_approval_requests_for(requisition)
    validate_requisition!(requisition)
    
    approvers = determine_approvers_for(requisition)
    create_approval_requests(requisition, approvers)
  end

  private

  def validate_requisition!(requisition)
    raise ArgumentError, 'Requisition must be present' unless requisition
    raise ArgumentError, 'Requisition must be persisted' unless requisition.persisted?
    raise ArgumentError, 'Salary must be present' if requisition.salary.nil?
  end

  def determine_approvers_for(requisition)
    approvers = base_approval_chain
    approvers += high_salary_approval_chain if high_salary?(requisition)
    approvers.uniq
  end

  def create_approval_requests(requisition, approvers)
    approvers.map do |role|
      ApprovalRequest.create!(
        requisition: requisition,
        approver_role: role,
        status: 'pending',
        due_at: calculate_due_date,
        created_by: requisition.created_by
      )
    end
  end

  def base_approval_chain
    ['finance_manager', 'hr_manager']
  end

  def high_salary_approval_chain
    ['cfo']
  end

  def high_salary?(requisition)
    requisition.salary > SALARY_THRESHOLD
  end

  def calculate_due_date
    date = Time.current

    APPROVAL_DUE_DAYS.times do
      date = next_business_day(date)
    end

    date.end_of_day
  end

  def next_business_day(date)
    date = date.tomorrow
    date = date.tomorrow while weekend?(date)
    date
  end

  def weekend?(date)
    date.saturday? || date.sunday?
  end
end
