Rails.application.config.ai_service = {
  endpoint: ENV.fetch('AI_SERVICE_ENDPOINT', 'http://ai-insights.example.com'),
  api_key: ENV.fetch('AI_SERVICE_API_KEY', nil),
  timeout: ENV.fetch('AI_SERVICE_TIMEOUT', 5).to_i,
  enabled: ENV.fetch('AI_SERVICE_ENABLED', 'false') == 'true'
}
