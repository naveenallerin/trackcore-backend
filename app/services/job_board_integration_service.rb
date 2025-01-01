require 'faraday'

class JobBoardIntegrationService
  def initialize
    @indeed_api_key = Rails.application.credentials.dig(:job_boards, :indeed, :api_key)
    @linkedin_api_key = Rails.application.credentials.dig(:job_boards, :linkedin, :api_key)
    @glassdoor_api_key = Rails.application.credentials.dig(:job_boards, :glassdoor, :api_key)
  end

  def post_to_indeed(requisition)
    payload = {
      title: requisition.title,
      description: requisition.description,
      company: requisition.company_name,
      location: requisition.location,
      salary: requisition.salary_range,
      jobType: requisition.employment_type
    }

    response = Faraday.post('https://api.indeed.com/v2/job-postings') do |req|
      req.headers['Authorization'] = "Bearer #{@indeed_api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json
    end

    create_log_entry(requisition, 'indeed', response)
    response.success?
  rescue => e
    create_error_log(requisition, 'indeed', e)
    false
  end

  def post_to_linkedin(requisition)
    payload = {
      author: "urn:li:organization:#{requisition.company_id}",
      job: {
        title: requisition.title,
        description: requisition.description,
        location: {
          country: requisition.country_code,
          city: requisition.city
        },
        employmentType: requisition.employment_type
      }
    }

    response = Faraday.post('https://api.linkedin.com/v2/jobPosts') do |req|
      req.headers['Authorization'] = "Bearer #{@linkedin_api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json
    end

    create_log_entry(requisition, 'linkedin', response)
    response.success?
  rescue => e
    create_error_log(requisition, 'linkedin', e)
    false
  end

  def post_to_glassdoor(requisition)
    payload = {
      jobTitle: requisition.title,
      jobDescription: requisition.description,
      company: requisition.company_name,
      location: requisition.location,
      employmentType: requisition.employment_type,
      salaryRange: requisition.salary_range,
      requirements: requisition.requirements
    }

    response = Faraday.post('https://partner-api.glassdoor.com/job-posts') do |req|
      req.headers['Authorization'] = "Bearer #{@glassdoor_api_key}"
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json
    end

    create_log_entry(requisition, 'glassdoor', response)
    response.success?
  rescue => e
    create_error_log(requisition, 'glassdoor', e)
    false
  end

  private

  def create_log_entry(requisition, board_name, response)
    JobBoardLog.create!(
      requisition_id: requisition.id,
      board_name: board_name,
      status: response.success? ? 'success' : 'failure',
      response_code: response.status,
      response_message: response.body
    )
  end

  def create_error_log(requisition, board_name, error)
    JobBoardLog.create!(
      requisition_id: requisition.id,
      board_name: board_name,
      status: 'failure',
      response_code: 'error',
      response_message: error.message
    )
  end
end
