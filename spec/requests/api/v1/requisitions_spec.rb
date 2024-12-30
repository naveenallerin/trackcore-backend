require 'rails_helper'

RSpec.describe 'Api::V1::Requisitions', type: :request do
  let(:user) { create(:user) }
  let(:requisition) { create(:requisition, user: user) }
  let(:headers) { valid_headers }

  before { sign_in user }

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

  describe "POST /api/v1/requisitions with template" do
    let(:template) { create(:template, body: "Position: {{POSITION}}, Department: {{DEPARTMENT}}") }
    let(:placeholders) do
      {
        "POSITION" => "Software Engineer",
        "DEPARTMENT" => "Engineering"
      }
    end

    it "creates a requisition with template-based description" do
      post api_v1_requisitions_path, params: {
        requisition: valid_attributes,
        template_id: template.id,
        placeholders: placeholders
      }

      expect(response).to have_http_status(:created)
      expect(json_response["description"]).to eq(
        "Position: Software Engineer, Department: Engineering"
      )
    end

    it "handles missing template gracefully" do
      post api_v1_requisitions_path, params: {
        requisition: valid_attributes,
        template_id: 999999
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to include("template_id")
    end
  end

  describe 'POST /api/v1/requisitions/:id/clone' do
    context 'when requisition exists' do
      it 'clones a requisition with all associations' do
        create(:requisition_field, requisition: requisition)
        create(:job_posting, requisition: requisition)

        expect {
          post clone_api_v1_requisition_path(requisition), headers: headers
        }.to change(Requisition, :count).by(1)
          .and change(RequisitionField, :count).by(1)
          .and change(JobPosting, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['title']).to eq("Copy of #{requisition.title}")
      end

      it 'sets correct default values for cloned requisition' do
        post clone_api_v1_requisition_path(requisition), headers: headers
        
        expect(json_response['status']).to eq('draft')
        expect(json_response['approval_state']).to eq('pending')
        expect(json_response['user_id']).to eq(user.id)
      end
    end

    context 'when requisition does not exist' do
      it 'returns not found status' do
        post clone_api_v1_requisition_path(0), headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/requisitions/bulk_create' do
    let(:valid_params) do
      {
        requisitions: [
          {
            title: 'Req 1',
            description: 'Desc 1',
            post_to_boards: ['linkedin']
          },
          {
            title: 'Req 2',
            description: 'Desc 2',
            post_to_boards: ['indeed', 'linkedin']
          }
        ]
      }
    end

    context 'with valid parameters' do
      it 'creates multiple requisitions' do
        expect {
          post bulk_create_api_v1_requisitions_path, 
               params: valid_params,
               headers: headers
        }.to change(Requisition, :count).by(2)
      end

      it 'enqueues job posting tasks' do
        expect {
          post bulk_create_api_v1_requisitions_path, 
               params: valid_params,
               headers: headers
        }.to have_enqueued_job(PostToJobBoardJob).exactly(3).times
      end

      it 'returns detailed success response' do
        post bulk_create_api_v1_requisitions_path, 
             params: valid_params,
             headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['success'].length).to eq(2)
        expect(json_response['success'].first).to include(
          'title',
          'description',
          'status'
        )
      end
    end

    context 'with partial failures' do
      let(:invalid_params) do
        {
          requisitions: [
            { title: '' },  # Invalid
            { title: 'Valid Title' }  # Valid
          ]
        }
      end

      it 'creates valid requisitions and reports errors' do
        expect {
          post bulk_create_api_v1_requisitions_path, 
               params: invalid_params,
               headers: headers
        }.to change(Requisition, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['success'].length).to eq(1)
        expect(json_response['errors'].length).to eq(1)
      end
    end

    context 'with invalid job boards' do
      let(:params_with_invalid_board) do
        {
          requisitions: [
            {
              title: 'Req 1',
              post_to_boards: ['invalid_board']
            }
          ]
        }
      end

      it 'handles invalid job board gracefully' do
        post bulk_create_api_v1_requisitions_path, 
             params: params_with_invalid_board,
             headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['errors']).to include(
          hash_including('errors' => include(match(/Invalid job board/)))
        )
      end
    end
  end

  describe 'POST /api/v1/requisitions/:id/request_approval' do
    it 'creates an approval request' do
      expect {
        post request_approval_api_v1_requisition_path(requisition),
             params: { approver_type: 'manager' },
             headers: headers
      }.to change(ApprovalRequest, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'GET /api/v1/requisitions/:id/approval_status' do
    it 'returns the current approval status' do
      get approval_status_api_v1_requisition_path(requisition), headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to be_present
    end
  end
end
