require 'rails_helper'

RSpec.describe Api::V1::DashboardLayoutsController, type: :request do
  let(:recruiter) { create(:user, role: 'recruiter') }
  let(:admin) { create(:user, role: 'admin') }
  let(:regular_widget) { create(:widget, role_restricted: false) }
  let(:restricted_widget) { create(:widget, role_restricted: true) }

  describe 'PUT /api/v1/dashboard_layout' do
    context 'as a recruiter' do
      before { sign_in recruiter }

      it 'can add non-restricted widgets' do
        put '/api/v1/dashboard_layout', params: { 
          widgets: [{ id: regular_widget.id, position: 0 }] 
        }
        
        expect(response).to have_http_status(:ok)
        expect(recruiter.reload.dashboard_layout.widget_ids).to include(regular_widget.id)
      end

      it 'cannot add restricted widgets' do
        put '/api/v1/dashboard_layout', params: { 
          widgets: [{ id: restricted_widget.id, position: 0 }] 
        }
        
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'as an admin' do
      before { sign_in admin }

      it 'can add any widget including restricted ones' do
        put '/api/v1/dashboard_layout', params: { 
          widgets: [
            { id: regular_widget.id, position: 0 },
            { id: restricted_widget.id, position: 1 }
          ] 
        }
        
        expect(response).to have_http_status(:ok)
        expect(admin.reload.dashboard_layout.widget_ids)
          .to contain_exactly(regular_widget.id, restricted_widget.id)
      end
    end
  end

  describe 'GET /api/v1/dashboard_layout' do
    context 'when user has no layout' do
      before { sign_in recruiter }

      it 'returns default layout' do
        get '/api/v1/dashboard_layout'
        
        expect(response).to have_http_status(:ok)
        expect(json_response[:layout]).to be_an(Array)
        expect(json_response[:layout].first).to include(:id, :position)
      end
    end

    context 'when user has custom layout' do
      before do
        sign_in recruiter
        recruiter.update(dashboard_layout: [{ id: regular_widget.id, position: 0 }])
      end

      it 'returns user custom layout' do
        get '/api/v1/dashboard_layout'
        
        expect(response).to have_http_status(:ok)
        expect(json_response[:layout]).to eq([{ 
          'id' => regular_widget.id, 
          'position' => 0 
        }])
      end
    end
  end
end
