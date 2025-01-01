gem 'faraday'

require 'faraday'
require 'base64'
require 'json'

class ResumeParsingService
  class ParsingError < StandardError; end
  
  SOVREN_API_ENDPOINT = 'https://rest.sovren.com/parser/resume'.freeze
  
  def initialize
    @account_id = Rails.application.credentials.sovren[:account_id]
    @service_key = Rails.application.credentials.sovren[:service_key]
  end

  def parse(file_or_text)
    document_content = file_or_text.is_a?(String) ? file_or_text : read_file(file_or_text)
    encoded_content = Base64.strict_encode64(document_content)
    
    response = make_api_request(encoded_content)
    parsed_data = process_response(response)
    
    # Enhance with AI analysis
    ai_analysis = enhance_with_ai(document_content, parsed_data[:skills])
    parsed_data.merge(ai_analysis)
  rescue Faraday::Error => e
    raise ParsingError, "API request failed: #{e.message}"
  rescue JSON::ParserError => e
    raise ParsingError, "Invalid JSON response: #{e.message}"
  end

  private

  def read_file(file)
    file.read
  rescue StandardError => e
    raise ParsingError, "Failed to read file: #{e.message}"
  end

  def make_api_request(encoded_content)
    connection.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Accept'] = 'application/json'
      req.headers['Sovren-AccountId'] = @account_id
      req.headers['Sovren-ServiceKey'] = @service_key
      req.body = {
        documentAsBase64String: encoded_content,
        outputHtml: false,
        configuration: {
          includeSkills: true,
          includeEducation: true,
          includeEmploymentHistory: true
        }
      }.to_json
    end
  end

  def connection
    @connection ||= Faraday.new(url: SOVREN_API_ENDPOINT) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def process_response(response)
    unless response.success?
      raise ParsingError, "API returned error status: #{response.status}"
    end

    data = response.body
    parsed_resume = data.dig('Value', 'ParsedDocument')

    {
      skills: extract_skills(parsed_resume),
      education: extract_education(parsed_resume),
      experience: extract_experience(parsed_resume),
      contact_info: extract_contact_info(parsed_resume)
    }
  end

  def enhance_with_ai(resume_text, explicit_skills)
    ai_analyzer = AiResumeAnalyzerService.new
    ai_analyzer.infer_skills(resume_text, explicit_skills)
  rescue AiResumeAnalyzerService::AnalysisError => e
    { implied_skills: [], skill_categories: {} }
  end

  def extract_skills(parsed_resume)
    skills_data = parsed_resume.dig('Skills', 'Raw') || []
    skills_data.map { |skill| skill['Name'] }
  end

  def extract_education(parsed_resume)
    education_data = parsed_resume.dig('Education', 'EducationHistory') || []
    education_data.map do |edu|
      {
        school: edu.dig('SchoolName', 'Raw'),
        degree: edu.dig('Degree', 'Name'),
        field_of_study: edu.dig('Major', 'Raw'),
        graduation_date: edu['LastEducationDate'],
      }
    end
  end

  def extract_experience(parsed_resume)
    experience_data = parsed_resume.dig('EmploymentHistory', 'Positions') || []
    experience_data.map do |position|
      {
        company: position.dig('Employer', 'Name', 'Raw'),
        title: position.dig('Title', 'Raw'),
        start_date: position['StartDate'],
        end_date: position['EndDate'],
        description: position.dig('Description', 'Raw')
      }
    end
  end

  def extract_contact_info(parsed_resume)
    contact_info = parsed_resume.dig('ContactInformation') || {}
    {
      name: contact_info.dig('CandidateName', 'FormattedName'),
      email: contact_info.dig('EmailAddresses', 0),
      phone: contact_info.dig('Telephones', 0, 'Raw'),
      location: contact_info.dig('Location', 'Municipality')
    }
  end
end
