module Auditable
  extend ActiveSupport::Concern

  included do
    before_save :set_audit_timestamps
    
    private

    def set_audit_timestamps
      self.updated_at = Time.current
      self.created_at = Time.current if new_record?
    end
  end
end
