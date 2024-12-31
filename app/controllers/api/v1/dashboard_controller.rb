module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: {
          candidate_counts: candidate_stats,
          requisitions_open: Requisition.where(status: :open).count,
          requisitions_closed: Requisition.where(status: :closed).count
        }
      end

      private

      def candidate_stats
        stats = Application.group(:application_status).count
        {
          applied: stats['applied'] || 0,
          screened: stats['screened'] || 0,
          interviewed: stats['interviewed'] || 0,
          offered: stats['offered'] || 0,
          hired: stats['hired'] || 0,
          rejected: stats['rejected'] || 0
        }
      end
    end
  end
end
