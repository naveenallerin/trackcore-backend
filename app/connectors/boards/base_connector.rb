module Boards
  class BaseConnector
    class PostingError < StandardError; end
    class RemovalError < StandardError; end

    def post(requisition)
      raise NotImplementedError, "#{self.class} must implement #post"
    end

    def remove(external_id)
      raise NotImplementedError, "#{self.class} must implement #remove"
    end

    private

    def handle_api_error(error)
      Rails.logger.error("[#{self.class}] API Error: #{error.message}")
      raise PostingError, "Failed to communicate with job board: #{error.message}"
    end
  end
end
