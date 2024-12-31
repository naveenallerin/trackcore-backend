# spec/requests/candidates_spec.rb

require 'rails_helper'

RSpec.describe 'Candidates API', type: :request do
  let(:job) { create(:job) }
  
  describe 'GET /api/v1/candidates' do
    it 'returns a list of candidates' do
      create_list(:candidate, 3, job: job)
      
      get '/api/v1/candidates', headers: json_headers
      
      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(3)
    end
  end

  describe 'POST /api/v1/candidates' do
    let(:valid_attributes) do
      {
        candidate: {
          job_id: job.id,
          first_name: 'John',
          last_name: 'Doe',
          email: 'john@example.com',
          status: 'new'
        }
      }
    end

    it 'creates a new candidate' do
      post '/api/v1/candidates', 
           headers: json_headers,
           params: valid_attributes.to_json

      expect(response).to have_http_status(:created)
      expect(json_response['email']).to eq('john@example.com')
    end
  end

  describe 'GET /candidates' do
    it 'returns an empty array when no candidates exist' do
      get '/candidates'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it 'returns all existing candidates' do
      FactoryBot.create(:candidate, first_name: 'John')
      FactoryBot.create(:candidate, first_name: 'Jane')

      get '/candidates'
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body.size).to eq(2)
      # Check that at least one of them is "John"
      first_names = body.map { |item| item['first_name'] }
      expect(first_names).to include('John', 'Jane')
    end
  end

  describe 'POST /candidates' do
    it 'creates a new candidate with valid attributes' do
      candidate_params = {
        candidate: {
          first_name: 'Alice',
          last_name:  'Wonderland',
          email:      'alice@example.com'
        }
      }

      post '/candidates',
           params:  candidate_params.to_json,
           headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body['id']).not_to be_nil
      expect(body['first_name']).to eq('Alice')
      expect(body['email']).to eq('alice@example.com')
    end

    it 'returns 422 if the candidate params are invalid' do
      candidate_params = {
        candidate: {
          first_name: '',
          last_name:  'User',
          email:      nil
        }
      }

      post '/candidates',
           params:  candidate_params.to_json,
           headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body['errors']).to include("Email can't be blank")
    end
  end

  describe 'GET /candidates/:id' do
    it 'returns the candidate with a valid id' do
      candidate = FactoryBot.create(:candidate, first_name: 'OneUser')
      get "/candidates/#{candidate.id}"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['first_name']).to eq('OneUser')
    end

    it 'returns 404 when the candidate is not found' do
      get '/candidates/9999'
      expect(response).to have_http_status(:not_found)

      body = JSON.parse(response.body)
      expect(body['error']).to eq('Candidate not found')
    end
  end

  describe 'PATCH /candidates/:id' do
    it 'updates an existing candidate with valid data' do
      candidate = FactoryBot.create(:candidate, first_name: 'OldName')
      patch "/candidates/#{candidate.id}",
            params: {
              candidate: { first_name: 'NewName' }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['first_name']).to eq('NewName')
    end

    it 'returns 404 if updating a non-existent candidate' do
      patch '/candidates/9999',
            params: { candidate: { first_name: 'NoMatter' } }.to_json,
            headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:not_found)

      body = JSON.parse(response.body)
      expect(body['error']).to eq('Candidate not found')
    end

    it 'returns 422 if update data is invalid' do
      candidate = FactoryBot.create(:candidate, email: 'valid@example.com')
      patch "/candidates/#{candidate.id}",
            params: {
              candidate: { email: '' } # invalid
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)
      expect(body['errors']).to include("Email can't be blank")
    end
  end

  describe 'DELETE /candidates/:id' do
    it 'deletes the candidate when found' do
      candidate = FactoryBot.create(:candidate)
      delete "/candidates/#{candidate.id}"
      expect(response).to have_http_status(:no_content)
      expect(Candidate.exists?(candidate.id)).to eq(false)
    end

    it 'returns 404 if the candidate does not exist' do
      delete '/candidates/9999'
      expect(response).to have_http_status(:not_found)

      body = JSON.parse(response.body)
      expect(body['error']).to eq('Candidate not found')
    end
  end
end