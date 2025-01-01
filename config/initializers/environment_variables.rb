required_variables = %w[
  INDEED_API_ENDPOINT
  INDEED_API_KEY
  LINKEDIN_API_ENDPOINT
  LINKEDIN_API_KEY
  LINKEDIN_COMPANY_ID
  GLASSDOOR_API_ENDPOINT
  GLASSDOOR_API_KEY
]

missing_variables = required_variables.select { |var| ENV[var].nil? }

if missing_variables.any?
  raise "Missing required environment variables: #{missing_variables.join(', ')}"
end
