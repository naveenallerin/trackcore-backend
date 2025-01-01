class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  rescue_from DashboardService::UnknownRoleError, with: :handle_unknown_role

  def index
    dashboard_data = Rails.cache.fetch("dashboard_widgets_#{current_user.id}", expires_in: 1.hour) do
      DashboardService.widgets_for(current_user)
    end

    render json: dashboard_data
  end

  def refresh_widget
    widget_type = params[:widget_type]
    fresh_data = DashboardService.new(current_user).send("#{widget_type}_data")
    render json: { type: widget_type, data: fresh_data, refreshed_at: Time.current }
  rescue NoMethodError
    render json: { error: "Invalid widget type" }, status: :bad_request
  end

  private

  def handle_unknown_role(exception)
    Rails.logger.error("Dashboard Error: #{exception.message}")
    render json: {
      error: "Configuration error",
      message: "No dashboard configuration found for your role",
      widgets: []
    }, status: :unprocessable_entity
  end
end