class HistoricalAnalysisService
  def initialize(metric_type:, start_date:, end_date:)
    @metric_type = metric_type
    @start_date = start_date
    @end_date = end_date
  end

  def year_over_year_analysis
    metrics = HistoricalMetric.by_date_range(@start_date, @end_date)
                             .by_metric_type(@metric_type)
                             .group_by { |m| m.recorded_at.year }
    
    calculate_yoy_changes(metrics)
  end

  def workflow_efficiency_metrics
    metrics = ApprovalRequest.group(:workflow_id)
      .select(
        'workflow_id',
        'AVG(EXTRACT(EPOCH FROM (completed_at - created_at)) / 3600) as avg_hours',
        'COUNT(*) as total_requests',
        'SUM(CASE WHEN status = \'approved\' THEN 1 ELSE 0 END) as approved_count'
      )
    
    metrics.map do |m|
      {
        workflow: m.workflow.name,
        avg_completion_hours: m.avg_hours.round(2),
        approval_rate: (m.approved_count.to_f / m.total_requests * 100).round(2)
      }
    end
  end

  def bias_analysis(demographic_field:, score_threshold: 70)
    groups = Candidate.group(demographic_field)
      .joins(:score_logs)
      .select(
        "#{demographic_field}",
        'AVG(score_logs.score) as avg_score',
        'COUNT(*) as total_candidates',
        'SUM(CASE WHEN score_logs.score < ? THEN 1 ELSE 0 END) as low_scores',
        score_threshold
      )

    highest_avg = groups.maximum('avg_score')
    
    groups.map do |group|
      {
        group: group[demographic_field],
        avg_score: group.avg_score.round(2),
        low_score_rate: (group.low_scores.to_f / group.total_candidates * 100).round(2),
        four_fifths_violation: (group.avg_score / highest_avg) < 0.8
      }
    end
  end

  def knockout_analysis
    KnockoutRule.all.map do |rule|
      total_runs = rule.knockout_logs.count
      {
        rule_name: rule.name,
        knockout_rate: (rule.knockout_logs.where(result: 'knocked_out').count.to_f / total_runs * 100).round(2),
        override_rate: (rule.knockout_logs.where(overridden: true).count.to_f / total_runs * 100).round(2)
      }
    end
  end

  private

  def calculate_yoy_changes(metrics_by_year)
    metrics_by_year.each_cons(2).map do |prev_year, current_year|
      year = current_year[0]
      prev_avg = prev_year[1].pluck(:value).average
      current_avg = current_year[1].pluck(:value).average
      percent_change = ((current_avg - prev_avg) / prev_avg * 100).round(2)
      
      {
        year: year,
        value: current_avg,
        percent_change: percent_change
      }
    end
  end
end
