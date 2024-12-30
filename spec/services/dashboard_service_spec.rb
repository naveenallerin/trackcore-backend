
require 'rails_helper'

RSpec.describe DashboardService do
  describe '.fetch_data_for' do
    let(:department) { 'Engineering' }

    context 'when user is a recruiter' do
      let(:user) { create(:user, role: 'recruiter') }
      
      it 'returns recruiter-specific metrics' do
        result = described_class.fetch_data_for(user)
        
        expect(result.keys).to match_array([
          :active_requisitions,
          :new_applications,
          :interviews_scheduled,
          :my_requisitions
        ])
      end
    end

    context 'when user is a manager' do
      let(:user) { create(:user, role: 'manager', department: department) }
      
      it 'returns manager-specific metrics' do
        result = described_class.fetch_data_for(user)
        
        expect(result.keys).to match_array([
          :department_openings,
          :offer_acceptance_rate,
          :pending_approvals,
          :total_applicants
        ])
      end

      it 'only includes data from user department' do
        create(:requisition, department: department)
        create(:requisition, department: 'Sales')
        
        result = described_class.fetch_data_for(user)
        expect(result[:department_openings]).to eq(1)
      end
    end

    context 'when user is an approver' do
      let(:user) { create(:user, role: 'approver') }
      
      it 'returns approval-related metrics' do
        result = described_class.fetch_data_for(user)
        
        expect(result.keys).to match_array([
          :pending_approvals,
          :approved_this_month
        ])
      end
    end
  end

  describe 'caching' do
    let(:user) { create(:user, role: 'recruiter') }
    let(:service) { described_class.new(user) }

    before do
      Rails.cache.clear
    end

    it 'caches the dashboard data' do
      expect(Requisition).to receive(:active).once.and_call_original
      
      2.times { service.fetch_data }
    end

    it 'invalidates cache when requisition is updated' do
      initial_data = service.fetch_data
      
      create(:requisition, status: 'active')
      
      new_data = service.fetch_data
      expect(new_data[:active_requisitions]).to eq(initial_data[:active_requisitions] + 1)
    end

    it 'invalidates cache after TTL expires' do
      expect(Requisition).to receive(:active).twice.and_call_original
      
      service.fetch_data
      travel DashboardService::CACHE_TTL + 1.minute
      service.fetch_data
    end

    it 'uses different cache keys for different users' do
      other_user = create(:user, role: 'manager', department: 'Sales')
      
      expect(Requisition).to receive(:active).twice.and_call_original
      
      described_class.fetch_data_for(user)
      described_class.fetch_data_for(other_user)
    end
  end
end
