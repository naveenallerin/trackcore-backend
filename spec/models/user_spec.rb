require 'rails_helper'

RSpec.describe User, type: :model do
  # ...existing code...
  
  describe 'dashboard configuration' do
    let(:user) { create(:user) }
    
    it 'starts with empty widget list' do
      expect(user.dashboard_config["widgets"]).to eq([])
    end
    
    describe '#add_widget' do
      it 'adds widget to config' do
        expect(user.add_widget("pending_interviews")).to be true
        expect(user.dashboard_config["widgets"]).to include("pending_interviews")
      end
      
      it 'prevents duplicate widgets' do
        user.add_widget("pending_interviews")
        expect(user.add_widget("pending_interviews")).to be false
      end
    end
    
    describe '#remove_widget' do
      before { user.add_widget("pending_interviews") }
      
      it 'removes widget from config' do
        expect(user.remove_widget("pending_interviews")).to be true
        expect(user.dashboard_config["widgets"]).not_to include("pending_interviews")
      end
      
      it 'returns false if widget not present' do
        expect(user.remove_widget("nonexistent")).to be false
      end
    end
  end
end
