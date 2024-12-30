require 'rails_helper'

RSpec.describe 'Api::V1::CandidatesController', type: :request do
  describe 'POST /api/v1/candidates/bulk_update' do
    let(:user) { create(:user) }
    let(:candidates) { create_list(:candidate, 3, status: 'Active') }
    let(:valid_params) do
      {
        candidate_ids: candidates.map(&:id),
        new_status: 'Rejected'
      }
    end

    before do
      sign_in user
    end

    context 'with valid parameters' do
      it 'updates candidates status and creates audit log' do
        expect {
          post '/api/v1/candidates/bulk_update', params: valid_params
        }.to change(AuditLog, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'success' => true,
          'success_count' => 3,
          'failure_count' => 0
        )
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing parameters' do
        post '/api/v1/candidates/bulk_update', params: { candidate_ids: [] }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /api/v1/candidates/:id/knockout_check' do
    let(:candidate) { create(:candidate) }
    let!(:rule) do
      create(:knockout_rule,
        rule_name: 'Location Check',
        condition_expression: 'location.nil?',
        rule_type: 'hard_knockout'
      )
    end

    it 'evaluates knockout rules for the candidate' do
      post "/api/v1/candidates/#{candidate.id}/knockout_check"
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'knocked_out' => true,
        'triggered_rules' => ['Location Check']
      )
    end
  end

  describe 'PATCH /api/v1/candidates/:id/override_score' do
    let(:candidate) { create(:candidate, computed_score: 50) }
    let(:valid_params) do
      {
        candidate: {
          overridden_score: 75,
          override_reason: 'Excellent interview performance'
        }
      }
    end

    it 'updates the override score and reason' do
      patch "/api/v1/candidates/#{candidate.id}/override_score", params: valid_params

      expect(response).to have_http_status(:ok)
      expect(candidate.reload.overridden_score).to eq(75)
      expect(candidate.override_reason).to eq('Excellent interview performance')
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { candidate: { overridden_score: nil } }
      end

      it 'returns unprocessable entity status' do
        patch "/api/v1/candidates/#{candidate.id}/override_score", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
