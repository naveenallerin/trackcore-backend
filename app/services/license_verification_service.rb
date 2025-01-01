class LicenseVerificationService
  class VerificationError < StandardError; end
  
  Result = Struct.new(:success?, :message, :data, keyword_init: true)
  
  def verify(candidate_license)
    response = make_api_request(candidate_license.license_number)
    
    if response.success?
      process_verification_response(candidate_license, response.body)
    else
      handle_error_response(response)
    end
  rescue Faraday::Error => e
    Result.new(
      success?: false,
      message: "API connection error: #{e.message}",
      data: nil
    )
  rescue JSON::ParserError => e
    Result.new(
      success?: false,
      message: "Invalid API response format: #{e.message}",
      data: nil
    )
  end

  private

  def make_api_request(license_number)
    connection.get("/licenses/#{license_number}") do |req|
      req.headers['Authorization'] = "Bearer #{api_key}"
      req.headers['Accept'] = 'application/json'
    end
  end

  def process_verification_response(candidate_license, response_body)
    license_data = JSON.parse(response_body)
    
    update_license_status(candidate_license, license_data)
    
    Result.new(
      success?: true,
      message: "License verified successfully",
      data: license_data
    )
  end

  def update_license_status(candidate_license, license_data)
    candidate_license.with_lock do
      candidate_license.status = determine_status(license_data)
      candidate_license.expiration_date = parse_date(license_data['expiration_date'])
      candidate_license.save!
    end
  end

  def determine_status(license_data)
    case license_data['status']&.downcase
    when 'active' then 'active'
    when 'expired' then 'expired'
    when 'revoked', 'suspended' then 'revoked'
    else 'unknown'
    end
  end

  def handle_error_response(response)
    error_message = begin
      JSON.parse(response.body)['error']
    rescue JSON::ParserError
      "HTTP #{response.status}: #{response.body}"
    end

    Result.new(
      success?: false,
      message: "License verification failed: #{error_message}",
      data: nil
    )
  end

  def connection
    @connection ||= Faraday.new(url: api_base_url) do |f|
      f.request :json
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end
  end

  def api_key
    @api_key ||= Rails.application.credentials.dig(:license_api, :api_key) ||
      raise(VerificationError, 'License API key not configured')
  end

  def api_base_url
    @api_base_url ||= Rails.application.credentials.dig(:license_api, :base_url) ||
      raise(VerificationError, 'License API base URL not configured')
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string)
  rescue Date::Error
    nil
  end
end
