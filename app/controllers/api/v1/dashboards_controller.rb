module Api
  module V1
    class DashboardsController < ApplicationController
      before_action :authenticate_user!
      before_action :authorize_dashboard_access!
      rescue_from ArgumentError, with: :handle_invalid_role

      rescue_from DashboardAggregationService::UnauthorizedRoleError do |e|
        render json: { error: e.message }, status: :forbidden
      end

      def index
        authorize :dashboard
        
        stats = if current_user.manager_or_admin?
                 DashboardService.new(current_user).advanced_stats
               else
                 DashboardService.new(current_user).basic_stats
               end

        render json: {
          data: stats,
          meta: {
            generated_at: Time.current,
            role: current_user.role
          }
        }
      rescue StandardError => e
        Rails.logger.error("Dashboard aggregation failed: #{e.message}")
        render json: { error: 'Failed to fetch dashboard data' }, status: :internal_server_error
      end

      def drill_down
        records = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          service = DashboardDrillDownService.new(
            user: current_user,
            metric: params[:metric]
          )
          service.call
        end

        if records
          render json: {
            data: paginate(records),
            meta: {
              total_count: records.size,
              filtered_by: current_user.role
            }
          }, status: :ok
        else
          render json: { 
            error: 'Invalid metric',
            valid_metrics: DashboardDrillDownService::VALID_METRICS 
          }, status: :bad_request
        end
      rescue StandardError => e
        Rails.logger.error("Drill-down failed: #{e.message}")
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end

      def basic
        stats = Rails.cache.fetch('dashboard_basic_stats', expires_in: 5.minutes) do
          DashboardService.basic_stats
        end
        
        render json: stats, status: :ok
      rescue StandardError => e
        Rails.logger.error("Dashboard stats generation failed: #{e.message}")
        render json: { error: 'Failed to generate dashboard stats' }, 
               status: :internal_server_error
      end

      private

      def dashboard_params
        params.permit(:timeframe, :department_id)
      end

      def authorize_dashboard_access!
        unless current_user.manager_or_admin?
          render json: { error: 'Access denied' }, status: :forbidden
        end
      end

      def handle_invalid_role(error)
        render json: { error: error.message }, status: :forbidden
      end

      def paginate(records)
        records.page(params[:page] || 1).per(params[:per_page] || 25)
      end

      def cache_key
        "dashboard_drill_down/#{current_user.id}/#{params[:metric]}/#{params[:page]}"
      end
    end
  end
end
