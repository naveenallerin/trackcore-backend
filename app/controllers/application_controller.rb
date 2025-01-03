# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Pagy::Backend
  include Pundit::Authorization
  include ActionController::MimeResponds
  
  # Only include authentication in non-test environments
  unless Rails.env.test?
    include ActionController::HttpAuthentication::Token::ControllerMethods
    before_action :authenticate_request
    before_action :check_rate_limit
  end
  
  before_action :authenticate_user!
  after_action :audit_api_request, if: :user_signed_in?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from AuthenticationError, with: :unauthorized
  rescue_from RateLimitExceeded, with: :too_many_requests
  rescue_from StandardError, with: :internal_server_error
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_request
    @current_user = AuthenticationService.authenticate(request.headers)
  rescue JWT::DecodeError
    raise AuthenticationError
  end

  def check_rate_limit
    key = "rate_limit:#{@current_user&.id}:#{request.ip}"
    count = REDIS_CLIENT.incr(key)
    REDIS_CLIENT.expire(key, 1.hour.to_i) if count == 1

    raise RateLimitExceeded if count > Rails.configuration.x.rate_limit.max_requests_per_hour
  end

  def paginate(resource)
    pagy, records = pagy(resource, items: params[:per_page] || 25)
    {
      data: records,
      pagination: {
        page: pagy.page,
        per_page: pagy.items,
        total_pages: pagy.pages,
        total_count: pagy.count
      }
    }
  end

  def not_found
    render json: { 
      error: 'Resource not found',
      status: 404,
      code: 'NOT_FOUND'
    }, status: :not_found
  end

  def unauthorized
    render json: {
      error: 'Unauthorized access',
      status: 401,
      code: 'UNAUTHORIZED'
    }, status: :unauthorized
  end

  def too_many_requests
    render json: {
      error: 'Rate limit exceeded',
      status: 429,
      code: 'RATE_LIMIT_EXCEEDED',
      retry_after: Time.current.beginning_of_hour + 1.hour
    }, status: :too_many_requests
  end

  def internal_server_error(exception)
    Rails.logger.error "Internal error: #{exception}\n#{exception.backtrace.join("\n")}"
    render json: {
      error: 'Internal server error',
      status: 500,
      code: 'INTERNAL_ERROR',
      request_id: request.request_id
    }, status: :internal_server_error
  end

  def bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
  end

  def audit_api_request
    return unless should_audit_request?

    current_user.log_activity(
      "api_#{request.method.downcase}",
      "#{request.method} #{request.path}"
    )
  end

  def should_audit_request?
    !['GET', 'HEAD'].include?(request.method) &&
      !request.path.start_with?('/health')
  end
end
