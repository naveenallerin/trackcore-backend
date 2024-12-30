module JobBoard
  class IndeedAdapter < BaseAdapter
    def post_job(job)
      with_error_handling do
        response = HTTParty.post(
          "#{api_url}/jobs",
          headers: headers,
          body: build_job_payload(job),
          timeout: timeout
        )
        handle_response(response)
      end
    end

    def update_job(job)
      response = HTTParty.put(
        "#{indeed_api_url}/jobs/#{job.external_job_id}",
        headers: headers,
        body: build_job_payload(job)
      )
      handle_response(response)
    end

    def remove_job(job)
      response = HTTParty.delete(
        "#{indeed_api_url}/jobs/#{job.external_job_id}",
        headers: headers
      )
      handle_response(response)
    end

    private

    def with_error_handling
      yield
    rescue HTTParty::TimeoutError
      raise JobBoard::Error, "Indeed API timeout"
    rescue JobBoard::RateLimitError => e
      # Add Indeed-specific rate limit handling
      Rails.logger.error("Indeed rate limit reached: #{e.message}")
      raise
    rescue JobBoard::ApiError => e
      # Add Indeed-specific error logging
      Rails.logger.error("Indeed API error: #{e.message}")
      raise
    end

    def indeed_api_url
      api_url
    end

    def headers
      {
        'Authorization' => "Bearer #{@credentials.api_key}",
        'Content-Type' => 'application/json'
      }
    end

    def build_job_payload(job)
      {
        title: job.title,
        description: job.description,
        location: job.location,
        salary: job.salary_range,
        company: job.company_name
      }.to_json
    end
  end
end
