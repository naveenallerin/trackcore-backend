require 'faraday'

class AiDescriptionService
  class AiError < StandardError; end

  def initialize
    @api_key = Rails.application.credentials.dig(:openai, :api_key)
    @api_url = 'https://api.openai.com/v1/chat/completions'
  end

  def generate_description(title:, current_description:, requirements:)
    prompt = create_prompt(title, current_description, requirements)
    
    response = Faraday.post(@api_url) do |req|
      req.headers['Authorization'] = "Bearer #{@api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: 'gpt-4',
        messages: [{
          role: 'user',
          content: prompt
        }],
        temperature: 0.7,
        max_tokens: 1000
      }.to_json
    end

    handle_response(response)
  rescue Faraday::Error => e
    raise AiError, "API request failed: #{e.message}"
  end

  private

  def create_prompt(title, current_description, requirements)
    <<~PROMPT
      As an AI expert in HR and recruitment, please enhance this job description:
      
      Title: #{title}
      
      Current Description:
      #{current_description}
      
      Requirements:
      #{requirements}
      
      Please provide a well-structured, professional job description that:
      1. Maintains all essential information from the original
      2. Improves clarity and engagement
      3. Uses inclusive language
      4. Highlights key responsibilities and qualifications
      5. Maintains a professional tone
    PROMPT
  end

  def handle_response(response)
    return parse_successful_response(response) if response.success?

    error_message = begin
      JSON.parse(response.body)['error']['message']
    rescue
      'Unknown error occurred'
    end

    raise AiError, "OpenAI API error: #{error_message}"
  end

  def parse_successful_response(response)
    data = JSON.parse(response.body)
    data.dig('choices', 0, 'message', 'content')&.strip ||
      raise(AiError, 'No content in response')
  end
end
