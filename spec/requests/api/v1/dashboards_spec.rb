require 'rails_helper'

RSpec.describe 'Api::V1::Dashboards', type: :request do
  let(:candidate) { create(:candidate) }

  describe 'GET /api/v1/dashboard' do
    before do
      sign_in candidate
      get '/api/v1/dashboard'
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns dashboard data' do
      expect(JSON.parse(response.body)).to include(
        'total_applications',
        'active_applications',
        'completed_applications'
      )
    end
  end

  describe 'GET /api/v1/dashboard' do
    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/v1/dashboard'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user, role: 'Recruiter') }
      
      it 'creates audit log on sign in and returns dashboard data' do
        expect {
          sign_in user
        }.to change(AuditLog, :count).by(1)

        audit_log = AuditLog.last
        expect(audit_log.action).to eq('sign_in')
        expect(audit_log.user_id).to eq(user.id)

        get '/api/v1/dashboard'

        expect(response).to have_http_status(:success)
        expect(json_response).to include(
          'data' => hash_including(
            'total_candidates',
            'active_requisitions'
          ),
          'meta' => hash_including(
            'generated_at',
            'role'
          )
        )
      end
    end

    context 'with different user roles' do
      let(:manager) { create(:user, role: 'Manager', department: 'Engineering') }
      let(:recruiter) { create(:user, role: 'Recruiter') }

      it 'returns role-specific data for manager' do
        sign_in manager
        get '/api/v1/dashboard'
        
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'department')).to be_present
      end

      it 'returns recruiter-specific data for recruiter' do
        sign_in recruiter
        get '/api/v1/dashboard'
        
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'requisitions')).to be_present
      end
    end
  end

  private

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
