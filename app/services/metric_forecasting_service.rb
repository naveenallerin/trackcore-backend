class MetricForecastingService
  def initialize(metric_type:, lookback_months: 24)
    @metric_type = metric_type
    @lookback_months = lookback_months
  end

  def forecast_next_quarter
    historical_data = fetch_historical_data
    return nil if historical_data.length < 6 # Need minimum data points
    
    trend = calculate_linear_trend(historical_data)
    project_future_value(trend)
  end

  private

  def fetch_historical_data
    start_date = @lookback_months.months.ago
    HistoricalMetric.by_metric_type(@metric_type)
                    .by_date_range(start_date, Date.current)
                    .order(:recorded_at)
  end

  def calculate_linear_trend(data)
    x = (0...data.length).to_a
    y = data.pluck(:value)
    
    x_mean = x.sum / x.length.to_f
    y_mean = y.sum / y.length.to_f
    
    slope = x.zip(y).sum { |xi, yi| (xi - x_mean) * (yi - y_mean) } / 
            x.sum { |xi| (xi - x_mean)**2 }
    
    intercept = y_mean - slope * x_mean
    
    { slope: slope, intercept: intercept }
  end

  def project_future_value(trend)
    next_x = @lookback_months + 3 # Project 3 months ahead
    trend[:slope] * next_x + trend[:intercept]
  end
end
