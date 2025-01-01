class CreateInsightJob < ApplicationJob
  queue_as :default

  def perform
    # Add insight creation logic here
  end
end
