require 'rails_helper'

RSpec.describe DashboardLayoutService do
  let(:service) { described_class.new(user) }
  let(:user) { create(:user, role: role) }
  let(:regular_widget) { create(:widget, role_restricted: false) }
  let(:restricted_widget) { create(:widget, role_restricted: true) }

  describe '#update_layout' do
    context 'with a recruiter user' do
      let(:role) { 'recruiter' }

      it 'updates layout with allowed widgets' do
        result = service.update_layout([
          { id: regular_widget.id, position: 0 }
        ])

        expect(result.success?).to be true
        expect(user.reload.dashboard_layout.widget_ids).to eq([regular_widget.id])
      end

      it 'fails when trying to add restricted widgets' do
        result = service.update_layout([
          { id: restricted_widget.id, position: 0 }
        ])

        expect(result.success?).to be false
        expect(result.error).to eq('Some widgets are not available for your role')
      end
    end
  end

  describe '#default_layout' do
    it 'returns role-appropriate default widgets' do
      default_layout = service.default_layout
      expect(default_layout).to be_an(Array)
      expect(default_layout.all? { |w| w[:id].present? }).to be true
    end
  end
end
