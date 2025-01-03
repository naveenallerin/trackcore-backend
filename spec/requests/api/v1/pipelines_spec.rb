require 'rails_helper'

RSpec.describe 'Api::V1::Pipelines', type: :request do
  let(:candidate) { create(:candidate) }
  
  describe 'GET /api/v1/pipelines' do
    before do
      sign_in candidate
      get '/api/v1/pipelines'
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of pipelines' do
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'GET /api/v1/pipelines/:id' do
    let(:pipeline) { create(:pipeline, candidate: candidate) }

    before do
      sign_in candidate
      get "/api/v1/pipelines/#{pipeline.id}"
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the requested pipeline' do
      expect(JSON.parse(response.body)['id']).to eq(pipeline.id)
    end
  end
end
