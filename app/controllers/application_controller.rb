# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  skip_before_action :verify_authenticity_token

  # Optionally, rescue from 404 or anything else:
  # rescue_from ActiveRecord::RecordNotFound do
  #   render json: { error: 'Not found' }, status: :not_found
  # end
end
