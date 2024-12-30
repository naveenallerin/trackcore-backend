class DashboardAggregationService

    # ...existing code...

  def build_dashboard
    {
      metrics: fetch_metrics,
      insights: {
        personal: fetch_personal_insights,
        global: fetch_global_insights,
        critical_alerts: fetch_critical_alerts,
        summary: generate_insight_summary
      },
      generated_at: Time.current
    }
  end

  private

  def fetch_personal_insights
    return [] unless user.can_view_ai_insights?

    Rails.cache.fetch("personal_insights/#{user.id}", expires_in: 5.minutes) do
      CandidateInsight.active
                      .personal
                      .joins(:candidate)
                      .merge(Candidate.accessible_by(user))
                      .order(severity: :desc)
                      .limit(5)
    end
  end

  def fetch_global_insights
    return [] unless user.can_view_global_insights?

    Rails.cache.fetch('global_insights', expires_in: 15.minutes) do
      CandidateInsight.active
                      .global
                      .order(created_at: :desc)
                      .limit(5)
    end
  end

  def fetch_critical_alerts
    return [] unless user.can_view_ai_insights?

    CandidateInsight.active
                    .by_severity('critical')
                    .joins(:candidate)
                    .merge(Candidate.accessible_by(user))
                    .limit(5)
  end

  def generate_insight_summary
    return {} unless user.can_view_ai_insights?

    {
      personal: summarize_insights(:personal),
      global: user.can_view_global_insights? ? summarize_insights(:global) : nil
    }.compact
  end

  def summarize_insights(type)
    insights = CandidateInsight.active.where(insight_type: type)
    insights = insights.joins(:candidate).merge(Candidate.accessible_by(user)) if type == :personal

    {
      total: insights.count,
      by_severity: insights.group(:severity).count,
      recent: insights.where('created_at > ?', 24.hours.ago).count
    }
  end
  # ...existing code...
end
