module Boards
  class LinkedInConnector < BaseConnector
    def post(requisition)
      # TODO: Implement actual LinkedIn API call
      begin
        response = LinkedIn::Jobs.create(
          job_title: requisition.title,
          description: requisition.description,
          location: requisition.location
        )
        response.urn
      rescue StandardError => e
        handle_api_error(e)
      end
    end

    def remove(external_id)
      # TODO: Implement actual LinkedIn API call
      begin
        LinkedIn::Jobs.delete(external_id)
        true
      rescue StandardError => e
        handle_api_error(e)
      end
    end
  end
end
