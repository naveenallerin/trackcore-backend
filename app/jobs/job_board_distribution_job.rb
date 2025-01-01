class JobBoardDistributionJob
  include Sidekiq::Job

  sidekiq_options queue: :job_boards, retry: 3

  def perform
    service = JobBoardIntegrationService.new
    
    Requisition.active.find_each do |requisition|
      distribute_to_boards(requisition, service)
    rescue StandardError => e
      Rails.logger.error("Failed to process requisition #{requisition.id}: #{e.message}")
      JobBoardLog.create!(
        requisition_id: requisition.id,
        board_name: 'all',
        status: 'failure',
        response_code: 'error',
        response_message: "Job distribution failed: #{e.message}"
      )
    end
  end

  private

  def distribute_to_boards(requisition, service)
    boards = {
      indeed: -> { service.post_to_indeed(requisition) },
      linkedin: -> { service.post_to_linkedin(requisition) },
      glassdoor: -> { service.post_to_glassdoor(requisition) }
    }

    boards.each do |board, posting_method|
      begin
        posting_method.call
      rescue StandardError => e
        Rails.logger.error("Failed to post requisition #{requisition.id} to #{board}: #{e.message}")
      end
    end
  end
end
