
require 'rails_helper'

RSpec.describe 'Api::V1::Requisitions', type: :request do
  describe 'POST /api/v1/requisitions' do
    let(:department) { create(:department) }
    let(:valid_attributes) do
      {
        requisition: {
          title: 'Software Engineer',
          department: 'Engineering',
          description: 'We are looking for...',
          custom_fields: [
            { key: 'experience', value: '5 years', field_type: 'string', required: true }
          ]
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new requisition' do
        expect {
          post '/api/v1/requisitions', params: valid_attributes
        }.to change(Requisition, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['title']).to eq('Software Engineer')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post '/api/v1/requisitions', params: { requisition: { title: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end
end
