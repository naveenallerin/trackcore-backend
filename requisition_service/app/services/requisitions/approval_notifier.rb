require 'faraday'

module Requisitions
  class ApprovalNotifier
    APPROVAL_SERVICE_URL = ENV['APPROVAL_SERVICE_URL'] || 'http://approval-service:3000'

    def initialize(approval_id)
      @approval_id = approval_id
    end

    def mark_complete
      response = connection.patch("/api/v1/approvals/#{@approval_id}/complete")
      handle_response(response)
    end

    private

    def connection
      @connection ||= Faraday.new(url: APPROVAL_SERVICE_URL) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      case response.status
      when 200
        OpenStruct.new(success?: true, data: response.body)
      else
        OpenStruct.new(success?: false, error: response.body['errors'])
      end
    end
  end
end
