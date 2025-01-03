class DashboardService
  CACHE_TTL = 5.minutes

  def self.fetch_data_for(user)
    new(user).fetch_data
  end

  def self.drill_down_data(user, metric)
    new(user).drill_down_data(metric)
  end

  def self.basic_stats
    {
      total_candidates: Candidate.count,
      total_pipelines: Pipeline.count,
      active_candidates: Candidate.where(status: 'active').count,
      pipeline_metrics: pipeline_metrics,
      metrics_updated_at: Time.current
    }
  end

  def initialize(user)
    @user = user
  end

  def fetch_data
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      data = case @user.role
      when 'recruiter'
        fetch_recruiter_data
      when 'manager'
        fetch_manager_data
      when 'approver'
        fetch_approver_data
      else
        fetch_basic_data
      end

      data.merge(
        layout: @user.dashboard_layout.layout,
        insights: InsightsService.fetch_highlights_for(@user)
      )
    end
  end

  def drill_down_data(metric)
    case metric
    when 'new_applications'
      fetch_new_applications
    when 'active_requisitions'
      fetch_active_requisitions
    when 'pending_approvals'
      fetch_pending_approvals
    else
      raise ArgumentError, "Invalid metric: #{metric}"
    end
  end

  private

  def cache_key
    components = [
      'dashboard',
      @user.id,
      @user.role,
      @user.department,
      Requisition.maximum(:updated_at).to_i
    ]
    
    Digest::SHA1.hexdigest(components.join('-'))
  end

  def fetch_recruiter_data
    {
      active_requisitions: Requisition.active.count,
      new_applications: Requisition.new_applications_count,
      interviews_scheduled: Requisition.pending_interviews_count,
      my_requisitions: @user.requisitions.active.count
    }
  end

  def fetch_manager_data
    {
      department_openings: Requisition.for_department(@user.department).active.count,
      offer_acceptance_rate: calculate_offer_acceptance_rate,
      pending_approvals: Requisition.pending_approval.for_department(@user.department).count,
      total_applicants: Requisition.for_department(@user.department).total_applicants_count
    }
  end

  def fetch_approver_data
    {
      pending_approvals: Requisition.pending_approval.count,
      approved_this_month: Requisition.approved_in_month(Time.current.month).count
    }
  end

  def fetch_basic_data
    {
      total_open_positions: Requisition.active.count
    }
  end

  def fetch_new_applications
    scope = Requisition.joins(:applications)
                      .where(applications: { status: 'new' })
                      .distinct

    scope = scope.for_department(@user.department) if @user.role == 'manager'
    scope = scope.where(user: @user) if @user.role == 'recruiter'

    scope.select('requisitions.*, applications.created_at as application_date')
         .order('applications.created_at DESC')
  end

  def fetch_active_requisitions
    scope = Requisition.active

    scope = scope.for_department(@user.department) if @user.role == 'manager'
    scope = scope.where(user: @user) if @user.role == 'recruiter'

    scope.order(created_at: :desc)
  end

  def fetch_pending_approvals
    scope = Requisition.pending_approval

    scope = scope.for_department(@user.department) if @user.role == 'manager'
    
    scope.order(updated_at: :desc)
  end

  def calculate_offer_acceptance_rate
    department_offers = Requisition.for_department(@user.department).offers_made_count
    return 0 if department_offers.zero?
    
    accepted_offers = Requisition.for_department(@user.department).offers_accepted_count
    (accepted_offers.to_f / department_offers * 100).round(2)
  end

  def self.pipeline_metrics
    {
      candidates_in_pipelines: Pipeline.joins(:candidates).distinct.count('candidates.id'),
      active_pipelines: Pipeline.where(status: 'active').count,
      avg_pipeline_size: average_pipeline_size
    }
  end

  def self.average_pipeline_size
    total_pipelines = Pipeline.count
    return 0 if total_pipelines.zero?
    
    (Pipeline.joins(:candidates).group('pipelines.id')
            .count.values.sum.to_f / total_pipelines).round(2)
  end
end
