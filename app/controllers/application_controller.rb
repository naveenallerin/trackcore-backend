# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def json_request?
    request.format.json?
  end

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
  end

  # Optionally, rescue from 404 or anything else:
  # rescue_from ActiveRecord::RecordNotFound do
  #   render json: { error: 'Not found' }, status: :not_found
  # end
end
