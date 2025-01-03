module Integrations
  class BaseService
    class IntegrationError < StandardError; end
    
    def initialize(api_key: nil, base_url: nil)
      @api_key = api_key
      @base_url = base_url
      @client = setup_client
    end

    private

    def setup_client
      Faraday.new(@base_url) do |conn|
        conn.request :json
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      return response if response.success?
      
      raise IntegrationError, "API Error: #{response.status} - #{response.body}"
    end

    def log_request(action, payload)
      Rails.logger.info("[Integration][#{self.class.name}] #{action}: #{payload}")
    end
  end
end
