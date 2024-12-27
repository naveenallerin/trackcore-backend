require 'rails_helper'

RSpec.describe 'Api::V1::Requisitions', type: :request do
  describe 'POST /api/v1/requisitions' do
    let(:department) { create(:department) }
    let(:valid_attributes) do
      {
        requisition: {
          title: 'New Equipment Request',
          description: 'Need new laptops',
          department_id: department.id,
          custom_fields: [
            { name: 'Quantity', field_type: 'number', value: '5' }
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
        expect(json_response['data']['attributes']['title']).to eq('New Equipment Request')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity status' do
        post '/api/v1/requisitions', params: { requisition: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
