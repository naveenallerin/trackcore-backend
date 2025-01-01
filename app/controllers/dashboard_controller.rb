class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  # Add caching for dashboard metrics
  caches_action :index, cache_path: -> { 
    "dashboards/#{current_user.id}/#{current_user.role}/#{Date.current.to_s}"
  }

  def index
    metrics = Rails.cache.fetch("dashboard_metrics_#{current_user.id}", expires_in: 1.hour) do
      case current_user.role
      when 'recruiter'
        recruiter_metrics
      when 'hiring_manager'
        hiring_manager_metrics
      when 'admin'
        admin_metrics
      else
        basic_metrics
      end
    end

    render json: {
      metrics: metrics,
      last_updated: Time.current,
      refresh_url: dashboard_refresh_path
    }
  end

  def refresh
    Rails.cache.delete("dashboard_metrics_#{current_user.id}")
    redirect_to dashboard_path
  end

  def health_check
    metrics = {
      cache_status: check_cache_health,
      database_status: check_database_health,
      last_cache_refresh: Rails.cache.read('last_dashboard_refresh'),
      record_counts: {
        requisitions: Requisition.count,
        candidates: Candidate.count,
        interviews: Interview.count
      }
    }
    
    render json: metrics
  end

  private

  def recruiter_metrics
    {
      open_requisitions: {
        count: Requisition.open.count,
        by_department: Requisition.open.group(:department_id).count,
        urgent: Requisition.open.where('target_date < ?', 30.days.from_now).count
      },
      candidates: {
        new_this_week: Candidate.where('created_at > ?', 1.week.ago).count,
        in_pipeline: Application.group(:status).count,
        pending_review: Application.pending_review.count
      },
      interviews: {
        scheduled_today: Interview.where(scheduled_at: Time.current.all_day).count,
        scheduled_this_week: Interview.scheduled_this_week.count,
        pending_feedback: Interview.needs_feedback.count
      },
      activities: recent_activities
    }
  end

  def hiring_manager_metrics
    dept = current_user.department
    dept_reqs = Requisition.where(department: dept)
    
    {
      department: {
        name: dept.name,
        open_positions: dept_reqs.open.count,
        total_budget: dept_reqs.sum(:budget),
        remaining_budget: dept_reqs.sum(:budget) - dept_reqs.sum(:hiring_cost)
      },
      candidates: {
        active: dept_reqs.joins(:candidates).merge(Candidate.active).distinct.count,
        by_stage: Application.where(requisition: dept_reqs).group(:status).count,
        top_rated: top_candidates_for_department(dept)
      },
      interviews: {
        upcoming: Interview.for_department(dept).upcoming.count,
        completed_pending_feedback: Interview.for_department(dept).needs_feedback.count
      },
      pipeline_health: calculate_pipeline_health(dept)
    }
  end

  def admin_metrics
    {
      total_open_requisitions: Requisition.open.count,
      total_candidates: Candidate.count,
      average_time_to_fill: calculate_average_time_to_fill,
      cost_per_hire: calculate_cost_per_hire,
      departments_hiring: Requisition.open.distinct.pluck(:department).count,
      offer_acceptance_rate: calculate_offer_acceptance_rate
    }
  end

  def basic_metrics
    {
      total_open_positions: Requisition.open.count
    }
  end

  def calculate_average_time_to_fill
    Requisition.filled.average('filled_at - created_at').to_i / 1.day
  end

  def calculate_cost_per_hire
    return 0 unless Requisition.filled.any?
    
    total_cost = Requisition.filled.sum(:hiring_cost)
    total_hires = Requisition.filled.count
    (total_cost / total_hires).round(2)
  end

  def calculate_offer_acceptance_rate
    total_offers = Offer.where('created_at > ?', 30.days.ago).count
    accepted_offers = Offer.accepted.where('created_at > ?', 30.days.ago).count
    
    return 0 if total_offers.zero?
    ((accepted_offers.to_f / total_offers) * 100).round(2)
  end

  def recent_activities
    Activity.where(user: current_user)
            .or(Activity.where(department: current_user.department))
            .order(created_at: :desc)
            .limit(10)
            .map(&:to_dashboard_format)
  end

  def top_candidates_for_department(department)
    Candidate.joins(:interviews)
            .where(requisitions: { department_id: department.id })
            .group('candidates.id')
            .having('AVG(interviews.rating) >= ?', 4)
            .limit(5)
            .select('candidates.*, AVG(interviews.rating) as avg_rating')
            .order('avg_rating DESC')
            .map { |c| { name: c.full_name, rating: c.avg_rating.round(1) } }
    stages = applications.group(:status).count
  end

  def calculate_pipeline_health(department)
    applications = Application.joins(:requisition)
                            .where(requisitions: { department_id: department.id })
    
    stages = applications.group(:status).count
    total = applications.count.to_f
    
    return {} if total.zero?
    
    stages.transform_values { |count| (count / total * 100).round(1) }
  end

  def check_cache_health
    Rails.cache.write('health_check', 'ok')
    Rails.cache.read('health_check') == 'ok'
  rescue StandardError
    false
  end

  def check_database_health
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue StandardError
    false
  end
end

    total = applications.count.to_f
    
    return {} if total.zero?
    
    stages.transform_values { |count| (count / total * 100).round(1) }
  end

  def handle_not_found(exception)
    Rails.logger.error("Dashboard Error: #{exception.message}")
      pipeline_health: {}
    }
  end
end

    render json: {
      error: 'Resource not found',
      candidates: { active: 0, by_stage: {} },
      interviews: { upcoming: 0, completed_pending_feedback: 0 },
      message: 'Some dashboard data is temporarily unavailable'
    }, status: :not_found
  end

  def handle_error(exception)
    Rails.logger.error("Dashboard Error: #{exception.message}")
    render json: {
      error: 'Internal server error',
      message: 'Unable to load dashboard data'
    }, status: :internal_server_error
  end

  def default_hiring_manager_metrics
    {
      department: { name: 'Unknown', open_positions: 0 },