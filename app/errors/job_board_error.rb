module JobBoard
  class Error < StandardError; end
  
  class ApiError < Error
    attr_reader :response, :code
    
    def initialize(response)
      @response = response
      @code = response.code
      super(build_message)
    end
    
    private
    
    def build_message
      "#{@code} - #{@response.body}"
    end
  end
  
  class RateLimitError < ApiError; end
  class AuthenticationError < ApiError; end
  class ValidationError < ApiError; end
end
