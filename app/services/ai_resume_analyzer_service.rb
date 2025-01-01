require 'openai'

class AiResumeAnalyzerService
  class AnalysisError < StandardError; end

  def initialize
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.dig(:openai, :api_key),
      request_timeout: 30
    )
  end

  def infer_skills(resume_text, explicit_skills = [])
    prompt = build_prompt(resume_text, explicit_skills)
    
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [{
          role: "system",
          content: "You are a technical recruiter expert at identifying both explicit and implicit technical skills from resume text. Return only JSON."
        }, {
          role: "user",
          content: prompt
        }],
        temperature: 0.7,
        response_format: { type: "json_object" }
      }
    )

    parse_response(response)
  rescue OpenAI::Error => e
    handle_openai_error(e)
  end

  private

  def build_prompt(resume_text, explicit_skills)
    <<~PROMPT
      Analyze this resume text and the already identified skills. Return JSON with two arrays:
      1. implied_skills: Technical skills that are implied but not explicitly stated
      2. skill_categories: Group all skills (explicit and implied) into relevant categories

      Resume text:
      #{resume_text}

      Explicit skills already identified:
      #{explicit_skills.join(', ')}

      Return format:
      {
        "implied_skills": ["skill1", "skill2"],
        "skill_categories": {
          "category1": ["skill1", "skill2"],
          "category2": ["skill3", "skill4"]
        }
      }
    PROMPT
  end

  def parse_response(response)
    return {} unless response.dig("choices", 0, "message", "content")

    JSON.parse(response["choices"][0]["message"]["content"])
  rescue JSON::ParserError => e
    raise AnalysisError, "Failed to parse AI response: #{e.message}"
  end

  def handle_openai_error(error)
    case error
    when OpenAI::Errors::Unauthorized
      raise AnalysisError, "Invalid API credentials"
    when OpenAI::Errors::RateLimitExceeded
      raise AnalysisError, "Rate limit exceeded"
    else
      raise AnalysisError, "AI analysis failed: #{error.message}"
    end
  end
end
