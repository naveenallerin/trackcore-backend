require 'rails_helper'

RSpec.describe 'API::V1::Integrations', type: :request do
  let(:headers) { { 'Authorization' => 'Bearer valid-token', 'Content-Type' => 'application/json' } }
  let(:requisition) { create(:requisition) }
  let(:valid_params) do
    {
      requisition_id: requisition.id,
      integration_type: 'ats',
      payload: { job_title: 'Software Engineer' }
    }
  end

  before do
    stub_const('ENV', ENV.to_hash.merge('INTEGRATION_API_KEY' => 'test-key'))
  end

  describe 'POST /api/v1/integrations' do
    context 'when successful' do
      before do
        stub_request(:post, "#{ENV['INTEGRATION_API_URL']}/jobs")
          .with(
            headers: { 'Authorization' => "Bearer #{ENV['INTEGRATION_API_KEY']}" },
            body: hash_including(valid_params[:payload])
          )
          .to_return(
            status: 200,
            body: { job_reference: 'JOB123', status: 'success' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'creates an integration and returns success response' do
        post '/api/v1/integrations', params: valid_params, headers: headers

        expect(response).to have_http_status(:success)
        expect(json_response['job_reference']).to eq('JOB123')
        expect(json_response['status']).to eq('success')
      end
    end

    context 'when requisition does not exist' do
      it 'returns 404 status' do
        post '/api/v1/integrations', 
             params: valid_params.merge(requisition_id: 999999), 
             headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to include('Requisition not found')
      end
    end

    context 'when external API validation fails' do
      before do
        stub_request(:post, "#{ENV['INTEGRATION_API_URL']}/jobs")
          .to_return(
            status: 422,
            body: { error: 'Invalid parameters' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns 502 status with error message' do
        post '/api/v1/integrations', params: valid_params, headers: headers

        expect(response).to have_http_status(:bad_gateway)
        expect(json_response['error']).to include('External API validation failed')
      end
    end

    context 'when external API times out' do
      before do
        stub_request(:post, "#{ENV['INTEGRATION_API_URL']}/jobs")
          .to_timeout
      end

      it 'returns 502 status with timeout message' do
        post '/api/v1/integrations', params: valid_params, headers: headers

        expect(response).to have_http_status(:bad_gateway)
        expect(json_response['error']).to include('Request timed out')
      end
    end

    context 'when authentication fails' do
      it 'returns 401 status without valid token' do
        post '/api/v1/integrations', 
             params: valid_params, 
             headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to include('Unauthorized')
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
