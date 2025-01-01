class CleanupStaleInsightsJob < ApplicationJob
  queue_as :default

  def perform
    # Add cleanup logic here
  end
end
