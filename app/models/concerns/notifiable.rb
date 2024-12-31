module Notifiable
  extend ActiveSupport::Concern

  included do
    after_create :create_notification
  end

  private

  def create_notification
    message = notification_message
    users_to_notify.each do |user|
      notification = user.notifications.create!(
        message: message,
        target: self
      )
      NotificationChannel.broadcast_to(
        "notifications_user_#{user.id}",
        notification.as_json
      )
    end
  end

  def notification_message
    raise NotImplementedError, "#{self.class} must implement #notification_message"
  end

  def users_to_notify
    raise NotImplementedError, "#{self.class} must implement #users_to_notify"
  end
end
