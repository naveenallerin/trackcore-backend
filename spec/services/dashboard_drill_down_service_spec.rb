require 'rails_helper'

RSpec.describe DashboardDrillDownService do
  let(:service) { described_class.new(user: user, metric: metric) }

  describe '#call' do
    context 'with new_candidates metric' do
      let(:metric) { 'new_candidates' }
      
      context 'when user is admin' do
        let(:user) { create(:user, role: 'admin') }
        let!(:candidates) { create_list(:candidate, 3, status: 'new') }

        it 'returns all new candidates' do
          expect(service.call).to match_array(candidates)
        end
      end

      context 'when user is manager' do
        let(:department) { create(:department) }
        let(:user) { create(:user, role: 'manager', department: department) }
        let!(:department_candidates) { create_list(:candidate, 2, status: 'new', department: department) }
        let!(:other_candidates) { create_list(:candidate, 2, status: 'new') }

        it 'returns only department candidates' do
          expect(service.call).to match_array(department_candidates)
        end
      end
    end

    context 'with pending_interviews metric' do
      let(:metric) { 'pending_interviews' }
      let(:department) { create(:department) }
      
      context 'when user is manager' do
        let(:user) { create(:user, role: 'manager', department: department) }
        let!(:department_interview) do
          create(:interview, :pending, 
                requisition: create(:requisition, department: department))
        end
        let!(:other_interview) { create(:interview, :pending) }

        it 'returns only department interviews' do
          result = service.call
          expect(result.length).to eq(1)
          expect(result.first[:id]).to eq(department_interview.id)
        end

        it 'includes required interview fields' do
          result = service.call.first
          expect(result).to include(
            :id,
            :candidate_name,
            :requisition_title,
            :scheduled_at,
            :status
          )
        end
      end
    end

    context 'with invalid metric' do
      let(:user) { create(:user) }
      let(:metric) { 'invalid_metric' }

      it 'returns nil' do
        expect(service.call).to be_nil
      end
    end

    context 'performance', :performance do
      let(:user) { create(:user, role: 'admin') }
      let(:metric) { 'new_candidates' }

      before do
        create_list(:candidate, 100, status: 'new')
      end

      it 'processes large datasets efficiently' do
        expect {
          Timeout.timeout(1) { service.call }
        }.not_to raise_error
      end
    end
  end
end
