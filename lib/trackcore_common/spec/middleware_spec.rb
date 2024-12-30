require 'spec_helper'
require 'rack/test'

RSpec.describe TrackcoreCommon::AuthMiddleware do
  include Rack::Test::Methods

  let(:app) { ->(env) { [200, env, ['OK']] } }
  let(:middleware) { described_class.new(app) }
  
  before do
    TrackcoreCommon.configure do |config|
      config.jwt_secret = 'test_secret'
    end
  end

  it 'returns 401 when no token is provided' do
    get '/'
    expect(last_response.status).to eq(401)
  end

  it 'allows request with valid token' do
    token = TrackcoreCommon::Auth.generate_token({ sub: 'user123' })
    header 'Authorization', "Bearer #{token}"
    get '/'
    expect(last_response.status).to eq(200)
  end
end
