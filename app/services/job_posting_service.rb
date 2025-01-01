require 'httparty'

class JobPostingService
  class PostingError < StandardError; end

  def initialize(job_data)
    @job_data = job_data
  end

  def post_to_all
    results = {}
    job_boards.each do |board|
      results[board] = send("post_to_#{board}")
    rescue StandardError => e
      Rails.logger.error("Failed to post to #{board}: #{e.message}")
      results[board] = { success: false, error: e.message }
    end
    results
  end

  private

  def job_boards
    [:indeed, :linkedin, :glassdoor]
  end

  def post_to_indeed
    response = HTTParty.post(
      ENV['INDEED_API_ENDPOINT'],
      body: indeed_payload,
      headers: { 'Authorization' => "Bearer #{ENV['INDEED_API_KEY']}" }
    )
    handle_response(response, :indeed)
  end

  def post_to_linkedin
    response = HTTParty.post(
      ENV['LINKEDIN_API_ENDPOINT'],
      body: linkedin_payload,
      headers: { 'Authorization' => "Bearer #{ENV['LINKEDIN_API_KEY']}" }
    )
    handle_response(response, :linkedin)
  end

  def post_to_glassdoor
    response = HTTParty.post(
      ENV['GLASSDOOR_API_ENDPOINT'],
      body: glassdoor_payload,
      headers: { 'Authorization' => "Bearer #{ENV['GLASSDOOR_API_KEY']}" }
    )
    handle_response(response, :glassdoor)
  end

  def handle_response(response, board)
    if response.success?
      { success: true, response: response.parsed_response }
    else
      { success: false, error: "#{board.to_s.capitalize} API error: #{response.code}" }
    end
  end

  def indeed_payload
    {
      job_title: @job_data.title,
      description: @job_data.description,
      location: @job_data.location,
      company: @job_data.company_name,
      salary: @job_data.salary_range
    }.to_json
  end

  def linkedin_payload
    {
      title: @job_data.title,
      description: @job_data.description,
      location: @job_data.location,
      company_id: ENV['LINKEDIN_COMPANY_ID'],
      salary: @job_data.salary_range
    }.to_json
  end

  def glassdoor_payload
    {
      jobTitle: @job_data.title,
      jobDescription: @job_data.description,
      location: @job_data.location,
      employerName: @job_data.company_name,
      salary: @job_data.salary_range
    }.to_json
  end
end
