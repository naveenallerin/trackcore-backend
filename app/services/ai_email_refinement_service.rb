require 'net/http'

class AiEmailRefinementService
  OPENAI_URL = "https://api.openai.com/v1/chat/completions".freeze
  MAX_RETRIES = 2
  
  class AIServiceError < StandardError; end

  def self.refine_template(content, tone: 'professional')
    new.refine_template(content, tone: tone)
  end

  def refine_template(content, tone: 'professional')
    response = make_ai_request(content, tone)
    
    {
      original: content,
      refined: response.dig('choices', 0, 'message', 'content'),
      suggestions: extract_suggestions(response),
      tone: tone,
      created_at: Time.current
    }
  rescue => e
    handle_error(e)
  end

  private

  def make_ai_request(content, tone)
    uri = URI(OPENAI_URL)
    http = setup_http_client(uri)
    
    request = build_request(uri, content, tone)
    response = execute_with_retries(http, request)
    
    parse_response(response)
  end

  def setup_http_client(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = true
      http.read_timeout = 30
      http.open_timeout = 5
    end
  end

  def build_request(uri, content, tone)
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{api_key}"
    request['Content-Type'] = 'application/json'
    request.body = {
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: system_prompt(tone)
        },
        {
          role: 'user',
          content: content
        }
      ],
      temperature: 0.7
    }.to_json
    request
  end

  def execute_with_retries(http, request)
    retries = 0
    begin
      http.request(request)
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      retries += 1
      raise if retries > MAX_RETRIES
      sleep(retries)
      retry
    end
  end

  def parse_response(response)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    else
      raise AIServiceError, "API request failed: #{response.code} - #{response.body}"
    end
  end

  def system_prompt(tone)
    <<~PROMPT
      You are an expert email editor focusing on professional communication.
      Review and refine the following email content to:
      1. Maintain a #{tone} tone
      2. Ensure inclusivity and accessibility
      3. Remove any potential biases
      4. Improve clarity and conciseness
      5. Maintain proper business etiquette
      
      Provide the refined version followed by specific improvement notes.
    PROMPT
  end

  def extract_suggestions(response)
    content = response.dig('choices', 0, 'message', 'content')
    return [] unless content

    # Extract suggestions section (assumed to be after the refined content)
    if content.include?("Improvements:")
      content.split("Improvements:").last.strip.split("\n")
    else
      []
    end
  end

  def handle_error(error)
    error_message = case error
    when AIServiceError
      error.message
    when JSON::ParserError
      "Invalid response from AI service"
    else
      "Unexpected error: #{error.message}"
    end

    Rails.logger.error("AI Email Refinement Error: #{error_message}")
    Honeybadger.notify(error) if defined?(Honeybadger)
    
    raise AIServiceError, error_message
  end

  def api_key
    Rails.application.credentials.dig(:openai, :api_key) or
      raise AIServiceError, "OpenAI API key not configured"
  end
end
