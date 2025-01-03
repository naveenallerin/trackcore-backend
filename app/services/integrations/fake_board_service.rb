module Integrations
  class FakeBoardService < BaseService
    def initialize(api_key: ENV['FAKE_BOARD_API_KEY'], 
                  base_url: ENV['FAKE_BOARD_BASE_URL'])
      super
    end

    def post_job(requisition)
      log_request('post_job', "Posting #{requisition.title}")
      
      response = @client.post('jobs') do |req|
        req.headers['Authorization'] = "Bearer #{@api_key}"
        req.body = build_job_payload(requisition)
      end

      handle_response(response)
    rescue Faraday::Error => e
      raise IntegrationError, "Network Error: #{e.message}"
    end

    private

    def build_job_payload(requisition)
      {
        title: requisition.title,
        description: requisition.description,
        location: requisition.department&.location,
        salary_range: requisition.salary_range,
        external_reference: requisition.id,
        metadata: {
          department: requisition.department_name,
          source: 'ATS'
        }
      }
    end
  end
end
