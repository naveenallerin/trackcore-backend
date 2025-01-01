class HealthController < ApiController
  def show
    Rails.logger.info "Health check requested"
    render json: { 
      status: 'healthy', 
      timestamp: Time.current,
      environment: Rails.env
    }
  end
end
