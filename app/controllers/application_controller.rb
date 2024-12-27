# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Pundit::Authorization
  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
  end

  # Optionally, rescue from 404 or anything else:
  # rescue_from ActiveRecord::RecordNotFound do
  #   render json: { error: 'Not found' }, status: :not_found
  # end
end
