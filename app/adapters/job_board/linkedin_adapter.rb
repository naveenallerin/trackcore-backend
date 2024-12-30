module JobBoard
  class LinkedinAdapter < BaseAdapter
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
      with_error_handling do
        response = HTTParty.patch(
          "#{api_url}/jobs/#{job.external_job_id}",
          headers: headers,
          body: build_job_payload(job),
          timeout: timeout
        )
        handle_response(response)
      end
    end

    def remove_job(job)
      with_error_handling do
        response = HTTParty.delete(
          "#{api_url}/jobs/#{job.external_job_id}",
          headers: headers,
          timeout: timeout
        )
        handle_response(response)
      end
    end

    private

    def with_error_handling
      yield
    rescue HTTParty::TimeoutError
      raise JobBoard::Error, "LinkedIn API timeout"
    rescue JobBoard::RateLimitError => e
      Rails.logger.error("LinkedIn rate limit reached: #{e.message}")
      raise
    rescue JobBoard::ApiError => e
      Rails.logger.error("LinkedIn API error: #{e.message}")
      raise
    end

    def headers
      {
        'Authorization' => "Bearer #{@credentials.api_key}",
        'X-Restli-Protocol-Version' => '2.0.0',
        'Content-Type' => 'application/json'
      }
    end

    def build_job_payload(job)
      {
        title: job.title,
        description: job.description,
        location: {
          country: job.country_code,
          city: job.city
        },
        employment_type: map_employment_type(job.employment_type),
        industry: job.industry,
        company_id: @credentials.additional_settings['company_id']
      }.to_json
    end

    def map_employment_type(type)
      {
        'full_time' => 'F',
        'part_time' => 'P',
        'contract' => 'C',
        'temporary' => 'T',
        'internship' => 'I'
      }[type] || 'F'
    end
  end
end
