# Example API calls:
#
# Pipeline metrics:
#   GET /analytics/pipeline
#   GET /analytics/pipeline?start_date=2023-01-01&end_date=2023-12-31
#
# DEI summary (requires proper authorization):
#   GET /analytics/dei
#
# Time to fill metrics:
#   GET /analytics/time_to_fill
#   GET /analytics/time_to_fill?requisition_id=123
#
# Export endpoints:
#   GET /analytics/export?type=pipeline&format=csv
#   GET /analytics/export?type=dei&format=xlsx
#   GET /analytics/export?type=time_to_fill&format=csv&start_date=2023-01-01
#
# Example Response Format:
# {
#   "success": true,
#   "data": {
#     // metrics from AnalyticsService
#   }
# }

class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_analytics_access!

  def pipeline
    start_date = params.fetch(:start_date, 30.days.ago)
    end_date = params.fetch(:end_date, Time.current)

    render json: {
      success: true,
      data: AnalyticsService.candidate_pipeline_metrics(start_date, end_date)
    }
  end

  def dei
    authorize! :view_dei_data, current_user
    
    render json: {
      success: true,
      data: AnalyticsService.dei_summary
    }
  end

  def time_to_fill
    requisition_id = params[:requisition_id]
    
    render json: {
      success: true,
      data: AnalyticsService.time_to_fill(requisition_id)
    }
  end

  def export
    type = params.fetch(:type)
    start_date = params[:start_date]
    end_date = params[:end_date]

    respond_to do |format|
      format.csv do
        send_data ExportService.generate_csv(type, start_date, end_date),
                 filename: "#{type}_#{Date.current}.csv",
                 type: 'text/csv'
      end
      
      format.xlsx do
        package = ExportService.generate_xlsx(type, start_date, end_date)
        send_data package.to_stream.read,
                 filename: "#{type}_#{Date.current}.xlsx",
                 type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      end
    end
  rescue ArgumentError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def authorize_analytics_access!
    unless current_user.has_any_role?(:admin, :hr_analyst, :recruiter_manager)
      render json: { error: 'Unauthorized' }, status: :forbidden
    end
  end
end
