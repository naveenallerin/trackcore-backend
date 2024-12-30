module Postings
  class PublishJobService
    # Usage:
    # rails runner "Postings::PublishJobService.new(requisition_id: 1, board_name: 'indeed').call"
    # Or in console:
    # > service = Postings::PublishJobService.new(requisition_id: 1, board_name: 'indeed')
    # > service.call

    def initialize(requisition_id:, board_name:)
      @requisition_id = requisition_id
      @board_name = board_name.downcase
    end

    def call
      find_or_create_job_posting
      post_to_board
      @job_posting
    rescue StandardError => e
      handle_error(e)
      @job_posting
    end

    private

    def find_or_create_job_posting
      @job_posting = JobPosting.find_or_initialize_by(
        requisition_id: @requisition_id,
        board_name: @board_name
      )
      @job_posting.status = "pending"
      @job_posting.save!
    end

    def post_to_board
      connector = Boards::ConnectorFactory.build(@board_name)
      requisition = Requisition.find(@requisition_id)
      
      external_id = connector.post(requisition)
      
      @job_posting.update!(
        external_reference_id: external_id,
        status: "posted"
      )
    end

    def handle_error(error)
      Rails.logger.error("[PublishJobService] Failed to post job: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n"))
      
      @job_posting.update!(
        status: "failed"
      )
      
      # Optionally re-raise the error if you want to handle it upstream
      # raise error
    end
  end
end
