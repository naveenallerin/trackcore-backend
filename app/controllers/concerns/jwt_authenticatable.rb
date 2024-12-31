module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_user!
    header = request.headers['Authorization']
    if header.present?
      token = header.split(' ').last
      begin
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base).first
        @current_user = User.find(decoded['user_id'])
      rescue JWT::ExpiredSignature, JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing token' }, status: :unauthorized
    end
  end
end
