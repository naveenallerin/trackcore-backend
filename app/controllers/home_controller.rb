class HomeController < ApiController
  def index
    Rails.logger.info "Handling root request"
    render json: { status: 'ok', message: 'TrackCore API is running' }
  end
end
