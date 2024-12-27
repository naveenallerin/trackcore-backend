class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def show
    render json: {
      status: 'ok',
      version: Rails.application.config.version,
      timestamp: Time.current
    }
  end
end
