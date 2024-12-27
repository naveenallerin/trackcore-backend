module Api
    class BaseController < ActionController::API
        include ActionController::RequestForgeryProtection
        protect_from_forgery with: :null_session
        skip_before_action :verify_authenticity_token
        rescue_from ActiveRecord::RecordNotFound do |e|
            render json: { error: e.message }, status: :not_found
          end
      
          rescue_from ActiveRecord::RecordInvalid do |e|
            render json: { errors: e.record.errors }, status: :unprocessable_entity
          end
      
          private
      
          def render_error(message, status = :unprocessable_entity)
            render json: { error: message }, status: status
          end
        end
    end