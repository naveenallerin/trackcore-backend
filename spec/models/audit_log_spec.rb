require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:candidate_ids) }
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    it 'bulk_updates returns only bulk update actions' do
      bulk = create(:audit_log, action: 'bulk_update')
      other = create(:audit_log, action: 'other')
      
      expect(AuditLog.bulk_updates).to include(bulk)
      expect(AuditLog.bulk_updates).not_to include(other)
    end
  end
end
