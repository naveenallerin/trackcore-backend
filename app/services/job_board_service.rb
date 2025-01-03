class JobBoardService
  def initialize(job_board)
    @job_board = job_board
    @adapter = create_adapter
  end

  def post_job(job)
    @adapter.post_job(job)
  end

  def update_job(job)
    @adapter.update_job(job)
  end

  def remove_job(job)
    @adapter.remove_job(job)
  end

  class << self
    def post_to_boards(requisition_id)
      requisition = Requisition.find(requisition_id)
      
      IntegrationConfig.where(active: true).find_each do |config|
        JobBoardWorker.perform_async(
          requisition_id,
          config.id
        )
      end
    end

    def sync_postings
      IntegrationConfig.where(active: true).find_each do |config|
        JobBoardSyncWorker.perform_async(config.id)
      end
    end
  end

  private

  def create_adapter
    case @job_board.provider
    when 'indeed'
      IndeedAdapter.new(@job_board)
    when 'linkedin'
      LinkedinAdapter.new(@job_board)
    when 'ziprecruiter'
      ZipRecruiterAdapter.new(@job_board)
    else
      raise "Unsupported job board provider: #{@job_board.provider}"
    end
  end
end
