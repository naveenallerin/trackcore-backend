module Api
  module V1
    class TrendAnalysisController < ApplicationController
      def historical_metrics
        analysis = HistoricalAnalysisService.new(
          metric_type: params[:metric_type],
          start_date: params[:start_date],
          end_date: params[:end_date]
        ).year_over_year_analysis
        
        render json: { data: analysis }
      end

      def forecast
        forecast_value = MetricForecastingService.new(
          metric_type: params[:metric_type]
        ).forecast_next_quarter
        
        render json: { predicted_value: forecast_value }
      end
    end
  end
end
