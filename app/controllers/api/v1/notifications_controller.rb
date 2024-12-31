module Api
  module V1
    class NotificationsController < ApplicationController
      def index
        @notifications = current_user.notifications.order(created_at: :desc)
        render json: @notifications
      end

      def update
        @notification = current_user.notifications.find(params[:id])
        @notification.mark_as_read!
        render json: @notification
      end

      def mark_all_read
        current_user.notifications.unread.update_all(read_at: Time.current)
        head :ok
      end
    end
  end
end
