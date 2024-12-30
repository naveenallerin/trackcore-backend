module Api
  module V1
    class DashboardLayoutsController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: {
          layout: current_user.dashboard_layout.presence || service.default_layout
        }
      end

      def update
        result = service.update_layout(layout_params[:widgets])

        if result.success?
          render json: { message: 'Layout updated successfully' }
        else
          render json: { error: result.error }, status: :forbidden
        end
      end

      private

      def service
        @service ||= DashboardLayoutService.new(current_user)
      end

      def layout_params
        params.permit(widgets: [:id, :position])
      end
    end
  end
end
