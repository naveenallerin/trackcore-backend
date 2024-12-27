class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    health_status = HealthCheck.new.check
    status = health_status[:status] == 'error' ? :service_unavailable : :ok

    render json: health_status, status: status
  end
end
