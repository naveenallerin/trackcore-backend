
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(requisition_id, action)
    # Add notification logic
  end
end
