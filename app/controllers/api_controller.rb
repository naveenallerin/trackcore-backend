class ApiController < ActionController::API
  before_action :set_default_format
  rescue_from StandardError, with: :render_error

  private

  def set_default_format
    request.format = :json
  end

  def render_error(exception)
    Rails.logger.error("API Error: #{exception.message}\n#{exception.backtrace.join("\n")}")
    error_response = {
      error: exception.message,
      status: 500,
      request_id: request.request_id
    }
    render json: error_response, status: :internal_server_error
  end
end

class AddOauthToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_expires_at, :datetime
    
    add_index :users, [:provider, :uid], unique: true
  end
end
