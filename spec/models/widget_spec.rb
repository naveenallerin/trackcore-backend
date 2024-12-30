require 'rails_helper'

RSpec.describe Widget, type: :model do
  describe '#available_for?' do
    let(:widget) { build(:widget, role_restricted: role_restricted) }
    let(:admin) { build(:user, role: 'admin') }
    let(:recruiter) { build(:user, role: 'recruiter') }

    context 'when widget is role_restricted' do
      let(:role_restricted) { true }

      it 'is available for admin users' do
        expect(widget.available_for?(admin)).to be true
      end

      it 'is not available for recruiter users' do
        expect(widget.available_for?(recruiter)).to be false
      end
    end

    context 'when widget is not role_restricted' do
      let(:role_restricted) { false }

      it 'is available for all users' do
        expect(widget.available_for?(admin)).to be true
        expect(widget.available_for?(recruiter)).to be true
      end
    end
  end
end
