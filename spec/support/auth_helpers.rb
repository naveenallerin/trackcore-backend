module AuthHelpers
  def valid_auth_headers_for(user)
    token = JsonWebToken.encode(user_id: user.id)
    {
      'Authorization': "Bearer #{token}",
      'Accept': 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
