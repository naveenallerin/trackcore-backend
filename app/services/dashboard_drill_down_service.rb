class DashboardDrillDownService
  attr_reader :user, :metric

  def initialize(user:, metric:)
    @user = user
    @metric = metric
  end

  def call
    return unless VALID_METRICS.include?(metric.to_sym)
    
    send("fetch_#{metric}")
  end

  private

  VALID_METRICS = [
    :new_candidates,
    :open_requisitions,
    :pending_interviews,
    :department_applications
  ].freeze

  def fetch_new_candidates
    base_query = Candidate.where(status: 'new')
    
    case user.role
    when 'admin'
      base_query
    when 'manager'
      base_query.joins(:department).where(departments: { id: user.department_id })
    when 'recruiter'
      base_query.where(assigned_to: user)
    else
      Candidate.none
    end
  end

  def fetch_open_requisitions
    base_query = Requisition.where(status: 'open')
    
    case user.role
    when 'admin'
      base_query
    when 'manager'
      base_query.where(department_id: user.department_id)
    when 'recruiter'
      base_query.where(assigned_to: user)
    else
      Requisition.none
    end
  end

  def fetch_pending_interviews
    base_query = Interview.includes(:candidate, :requisition)
                        .where(status: 'pending')

    interviews = case user.role
                when 'admin'
                  base_query
                when 'manager'
                  base_query.where(requisitions: { department_id: user.department_id })
                when 'recruiter'
                  base_query.where(assigned_to: user)
                else
                  Interview.none
                end

    serialize_interviews(interviews)
  end

  def serialize_candidates(records)
    records.map do |candidate|
      {
        id: candidate.id,
        name: candidate.full_name,
        email: candidate.email,
        status: candidate.status,
        applied_at: candidate.created_at.iso8601,
        department: candidate.department&.name
      }
    end
  end

  def serialize_requisitions(records)
    records.map do |req|
      {
        id: req.id,
        title: req.title,
        department: req.department,
        status: req.status,
        created_at: req.created_at.iso8601,
        applications_count: req.applications.count
      }
    end
  end

  def serialize_interviews(records)
    records.map do |interview|
      {
        id: interview.id,
        candidate_name: interview.candidate.full_name,
        requisition_title: interview.requisition.title,
        scheduled_at: interview.scheduled_at.iso8601,
        status: interview.status
      }
    end
  end
end
