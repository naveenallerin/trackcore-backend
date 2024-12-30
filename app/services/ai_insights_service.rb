class AiInsightsService
  Error = Class.new(StandardError)
  TimeoutError = Class.new(Error)

  class << self
    def fetch_insights(user:)
      return [] unless enabled?
      
      new(user).fetch_insights
    rescue StandardError => e
      Rails.logger.error("AI Insights failed: #{e.message}")
      []
    end

    private

    def enabled?
      Rails.application.config.ai_service[:enabled]
    end
  end

  def initialize(user)
    @user = user
    @http_client = setup_http_client
  end

  def fetch_insights
    start_time = Time.now
    
    insights = if cached_insights.present?
      cached_insights
    else
      response = make_request
      insights = parse_insights(response)
      persist_insights(insights) if insights.present?
      insights
    end

    record_metrics(insights, start_time)
    insights
  rescue StandardError => e
    INSIGHT_ERRORS.increment(labels: { error_type: e.class.name })
    raise
  end

  private

  attr_reader :user, :http_client

  def cached_insights
    return [] unless user.can_view_ai_insights?

    insights = CandidateInsight.active
                              .joins(:candidate)
                              .order(severity: :desc)
                              .limit(10)

    insights = insights.merge(Candidate.accessible_by(user)) if personal_insights_only?
    insights = insights.personal if personal_insights_only?

    insights
  end

  def persist_insights(insights)
    insights.each do |insight|
      next if personal_insights_only? && insight[:insight_type] == 'global'
      next unless valid_insight?(insight)

      CreateInsightJob.perform_later(
        candidate_id: insight[:reference_id],
        category: insight[:insight_type],
        severity: insight[:severity],
        data: insight[:details],
        insight_type: insight[:insight_type],
        expires_at: expiry_for_type(insight[:insight_type])
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to persist insights: #{e.message}")
  end

  def valid_insight?(insight)
    return true if insight[:insight_type] == 'global'
    return false unless insight[:reference_id].present?
    
    case insight[:category]
    when 'candidate'
      Candidate.accessible_by(user).exists?(insight[:reference_id])
    when 'requisition'
      Requisition.accessible_by(user).exists?(insight[:reference_id])
    else
      false
    end
  end

  def personal_insights_only?
    !user.can_view_global_insights?
  end

  def expiry_for_type(type)
    case type
    when 'personal' then 24.hours.from_now
    when 'global' then 1.week.from_now
    end
  end

  def setup_http_client
    Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json
      f.headers['Authorization'] = "Bearer #{api_key}"
      f.adapter Faraday.default_adapter
    end
  end

  def make_request
    Timeout.timeout(config[:timeout]) do
      http_client.post('insights') do |req|
        req.body = request_payload
      end
    end
  rescue Timeout::Error
    raise TimeoutError, "AI service timeout after #{config[:timeout]} seconds"
  end

  def parse_insights(response)
    return [] unless response.success?

    response.body['insights'].map do |insight|
      {
        message: insight['message'],
        severity: insight['severity'],
        reference_id: insight['reference_id'],
        category: insight['category'],
        insight_type: insight['type'],
        details: insight['details'],
        action_url: build_action_url(insight),
        created_at: Time.current
      }
    end
  end

  def request_payload
    {
      user_role: user.role,
      department_id: user.department_id,
      context: gather_context
    }
  end

  def gather_context
    {
      recent_candidates: fetch_recent_candidates,
      pipeline_metrics: fetch_pipeline_metrics
    }
  end

  def fetch_recent_candidates
    Candidate.accessible_by(user)
            .recent
            .limit(10)
            .pluck(:id, :status)
  end

  def fetch_pipeline_metrics
    # Implementation depends on your metrics structure
    {}
  end

  def build_action_url(insight)
    case insight['category']
    when 'candidate'
      Rails.application.routes.url_helpers.candidate_path(insight['reference_id'])
    when 'requisition'
      Rails.application.routes.url_helpers.requisition_path(insight['reference_id'])
    end
  end

  def base_url
    config[:endpoint]
  end

  def api_key
    config[:api_key]
  end

  def config
    Rails.application.config.ai_service
  end

  def record_metrics(insights, start_time)
    duration = Time.now - start_time
    INSIGHT_GENERATION_TIME.observe(duration, labels: { insight_type: 'all' })

    insights.group_by { |i| i[:insight_type] }.each do |type, type_insights|
      type_insights.group_by { |i| i[:severity] }.each do |severity, sev_insights|
        INSIGHT_COUNT.increment(
          by: sev_insights.size,
          labels: { insight_type: type, severity: severity }
        )
      end
    end
  end
end
