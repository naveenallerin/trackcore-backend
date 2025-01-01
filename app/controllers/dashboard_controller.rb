class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    metrics = case current_user.role
              when 'recruiter'
                recruiter_metrics
              when 'hiring_manager'
                hiring_manager_metrics
              when 'admin'
                admin_metrics
              else
                basic_metrics
              end

    render json: metrics
  end

  private

  def recruiter_metrics
    {
      open_requisitions_count: Requisition.open.count,
      new_applicants_count: Candidate.where('created_at > ?', 1.week.ago).count,
      pending_reviews_count: Application.pending_review.count,
      interviews_this_week: Interview.scheduled_this_week.count
    }
  end

  def hiring_manager_metrics
    department_requisitions = Requisition.where(department: current_user.department)
    
    {
      department_requisitions_count: department_requisitions.count,
      department_open_positions: department_requisitions.open.count,
      active_candidates_count: department_requisitions.joins(:candidates)
                                                    .where(candidates: { status: 'active' })
                                                    .distinct
                                                    .count,
      upcoming_interviews: Interview.for_department(current_user.department)
                                  .upcoming
                                  .count
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
end
