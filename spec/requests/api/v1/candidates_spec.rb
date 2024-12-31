require 'rails_helper'

RSpec.describe 'Api::V1::Candidates', type: :request do
  describe 'GET /api/v1/candidates' do
    let!(:candidate1) { create(:candidate, status: 'interviewed', location: 'New York') }
    let!(:candidate2) { create(:candidate, status: 'applied', location: 'London') }

    it 'filters by status' do
      get '/api/v1/candidates', params: { status: 'interviewed' }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['id']).to eq(candidate1.id)
    end

    it 'filters by location' do
      get '/api/v1/candidates', params: { location: 'London' }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['id']).to eq(candidate2.id)
    end

    it 'returns empty array when no matches found' do
      get '/api/v1/candidates', params: { status: 'non_existent' }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end
end
