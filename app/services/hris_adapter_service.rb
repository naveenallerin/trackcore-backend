require 'net/http'

class HrisAdapterService
  class HrisError < StandardError; end

  def initialize
    @config = Rails.application.credentials.hris
    @base_url = @config[:base_url]
    @api_key = @config[:api_key]
  end

  def create_employee(candidate)
    response = make_request(
      'POST',
      '/onboarding',
      employee_payload(candidate)
    )
    
    Rails.logger.info("HRIS Response: #{response.body}")
    response
  rescue StandardError => e
    Rails.logger.error("HRIS Error: #{e.message}")
    raise HrisError, "HRIS integration failed: #{e.message}"
  end

  private

  def make_request(method, endpoint, payload = nil)
    uri = URI.parse("#{@base_url}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    http.open_timeout = 5

    request = build_request(method, uri, payload)
    response = http.request(request)

    handle_response(response)
  end

  def build_request(method, uri, payload)
    request = case method
              when 'POST' then Net::HTTP::Post.new(uri)
              when 'PUT'  then Net::HTTP::Put.new(uri)
              else raise ArgumentError, "Unsupported method: #{method}"
              end

    request['Authorization'] = "Bearer #{@api_key}"
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json if payload
    request
  end

  def handle_response(response)
    case response.code.to_i
    when 200..299
      response
    when 401
      raise HrisError, 'Invalid API credentials'
    when 429
      raise HrisError, 'Rate limit exceeded'
    else
      raise HrisError, "HRIS error: #{response.body}"
    end
  end

  def employee_payload(candidate)
    {
      firstName: candidate.first_name,
      lastName: candidate.last_name,
      email: candidate.email,
      startDate: candidate.start_date.iso8601,
      department: candidate.department,
      position: candidate.position_title,
      employeeType: 'FULL_TIME'
    }
  end
end
