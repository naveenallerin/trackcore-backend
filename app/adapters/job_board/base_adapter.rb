module JobBoard
  class BaseAdapter
    include Retryable

    def initialize(job_board)
      @job_board = job_board
      @credentials = job_board.credentials
    end

    def post_job(job)
      with_retries do
        perform_post_job(job)
      end
    end

    def update_job(job)
      raise NotImplementedError
    end

    def remove_job(job)
      raise NotImplementedError
    end

    protected

    def perform_post_job(job)
      raise NotImplementedError
    end

    private

    def handle_response(response)
      return response if response.success?
      
      case response.code
      when 401, 403
        raise JobBoard::AuthenticationError.new(response)
      when 422
        raise JobBoard::ValidationError.new(response)
      when 429
        raise JobBoard::RateLimitError.new(response)
      else
        raise JobBoard::ApiError.new(response)
      end
    end

    def config
      Rails.application.credentials.job_boards[@job_board.provider.to_sym]
    end

    def api_url
      Rails.env.production? ? config[:api_url] : config[:sandbox_api_url]
    end

    def timeout
      config[:timeout]
    end
  end
end
