require 'rails_helper'

RSpec.describe 'Api::V1::Dashboards', type: :request do
  describe 'GET /api/v1/dashboard' do
    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/v1/dashboard'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is a recruiter' do
      let(:user) { create(:user, role: 'Recruiter') }
      let!(:requisition) { create(:requisition, user: user) }
      
      before do
        create(:application, requisition: requisition)
        create(:interview, requisition: requisition)
        sign_in user
      end

      it 'returns success with recruiter metrics' do
        get '/api/v1/dashboard'

        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'requisitions')).to include(
          'total_active',
          'my_requisitions'
        )
      end

      it 'includes metadata' do
        get '/api/v1/dashboard'

        expect(json_response['meta']).to include(
          'generated_at',
          'role'
        )
      end
    end

    context 'when user is a manager' do
      let(:department) { create(:department, name: 'Engineering') }
      let(:user) { create(:user, role: 'Manager', department: department.name) }
      
      before do
        create_list(:requisition, 2, department: department.name)
        create(:requisition, department: 'Sales')
        sign_in user
      end

      it 'returns only department data' do
        get '/api/v1/dashboard'

        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'department', 'open_positions')).to eq(2)
      end
    end

    context 'with invalid role' do
      let(:user) { create(:user, role: 'Invalid') }
      
      before { sign_in user }

      it 'returns forbidden status' do
        get '/api/v1/dashboard'
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with performance concerns', :performance do
      let(:user) { create(:user, role: 'Admin') }
      
      before do
        create_list(:requisition, 100, :with_candidates)
        sign_in user
      end

      it 'responds within acceptable time' do
        start_time = Time.current
        get '/api/v1/dashboard'
        response_time = Time.current - start_time

        expect(response_time).to be < 2.seconds
        expect(response).to have_http_status(:success)
      end
    end

    context 'with AI insights' do
      let(:user) { create(:user, role: 'manager') }
      let(:mock_insights) do
        [{
          message: 'High drop-out risk detected',
          severity: 'high',
          reference_id: 123,
          category: 'candidate'
        }]
      end

      before do
        allow(AiInsightsService).to receive(:fetch_insights)
          .with(user: user)
          .and_return(mock_insights)
        sign_in user
      end

      it 'includes AI insights in response' do
        get '/api/v1/dashboard'
        
        expect(response).to have_http_status(:success)
        expect(json_response['insights']).to be_present
        expect(json_response['insights'].first['message']).to eq('High drop-out risk detected')
      end
    end

    context 'with AI insights' do
      let(:admin) { create(:user, role: 'admin') }
      let(:manager) { create(:user, role: 'manager') }
      
      let(:personal_insight) do
        {
          message: 'Candidate may drop out',
          severity: 'high',
          insight_type: 'personal',
          reference_id: 123
        }
      end

      let(:global_insight) do
        {
          message: 'Time-to-fill increasing',
          severity: 'medium',
          insight_type: 'global'
        }
      end

      it 'shows both personal and global insights to admin' do
        sign_in admin
        allow(AiInsightsService).to receive(:fetch_insights)
          .and_return([personal_insight, global_insight])

        get '/api/v1/dashboard'
        
        expect(response).to have_http_status(:success)
        expect(json_response.dig('insights', 'personal')).to be_present
        expect(json_response.dig('insights', 'global')).to be_present
      end

      it 'shows only personal insights to manager' do
        sign_in manager
        allow(AiInsightsService).to receive(:fetch_insights)
          .and_return([personal_insight])

        get '/api/v1/dashboard'
        
        expect(response).to have_http_status(:success)
        expect(json_response.dig('insights', 'personal')).to be_present
        expect(json_response.dig('insights', 'global')).to be_empty
      end
    end

    context 'with mixed insights' do
      let(:admin) { create(:user, role: 'admin') }
      let(:recruiter) { create(:user, role: 'recruiter') }
      
      let(:mock_insights) do
        [
          {
            message: 'Personal insight',
            severity: 'high',
            insight_type: 'personal',
            reference_id: 1
          },
          {
            message: 'Global insight',
            severity: 'medium',
            insight_type: 'global'
          }
        ]
      end

      before do
        allow(AiInsightsService).to receive(:fetch_insights)
          .with(user: admin)
          .and_return(mock_insights)
      end

      it 'shows all insights to admin' do
        sign_in admin
        get '/api/v1/dashboard'
        
        insights = json_response.dig('insights')
        expect(insights['personal']).to be_present
        expect(insights['global']).to be_present
      end

      it 'filters global insights for recruiter' do
        sign_in recruiter
        allow(AiInsightsService).to receive(:fetch_insights)
          .with(user: recruiter)
          .and_return(mock_insights.select { |i| i[:insight_type] == 'personal' })
        
        get '/api/v1/dashboard'
        
        insights = json_response.dig('insights')
        expect(insights['personal']).to be_present
        expect(insights['global']).to be_empty
      end
    end
  end

  describe "GET /api/v1/dashboard/drill_down" do
    let(:user) { create(:user) }
    let(:headers) { valid_auth_headers_for(user) }

    context "when requesting new applications" do
      before do
        create(:requisition, :with_new_application)
        create(:requisition, :with_rejected_application)
      end

      it "returns only requisitions with new applications" do
        get "/api/v1/dashboard/drill_down", params: { metric: 'new_applications' }, headers: headers
        
        expect(response).to have_http_status(:success)
        expect(json_response.length).to eq(1)
        expect(json_response.first).to include('application_date')
      end
    end

    context "when user is a manager" do
      let(:user) { create(:user, role: 'manager', department: 'Engineering') }
      
      before do
        create(:requisition, department: 'Engineering', status: 'active')
        create(:requisition, department: 'Sales', status: 'active')
      end

      it "returns only department requisitions" do
        get "/api/v1/dashboard/drill_down", params: { metric: 'active_requisitions' }, headers: headers
        
        expect(response).to have_http_status(:success)
        expect(json_response.length).to eq(1)
        expect(json_response.first['department']).to eq('Engineering')
      end
    end

    context "with invalid metric" do
      it "returns bad request status" do
        get "/api/v1/dashboard/drill_down", params: { metric: 'invalid' }, headers: headers
        
        expect(response).to have_http_status(:bad_request)
        expect(json_response['error']).to include('Invalid metric')
      end
    end
  end

  describe 'GET /api/v1/dashboards/drill_down' do
    let(:user) { create(:user) }
    
    before do
      sign_in user
    end

    context 'with valid metric' do
      it 'returns paginated results' do
        get '/api/v1/dashboards/drill_down', params: { metric: 'new_candidates' }
        
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('data')
      end
    end

    context 'with invalid metric' do
      it 'returns bad request' do
        get '/api/v1/dashboards/drill_down', params: { metric: 'invalid' }
        
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  private

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
