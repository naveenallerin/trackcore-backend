class AuditLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :by_action, ->(action) { where(action: action) }

  def self.record(user, action, details = nil)
    create!(
      user: user,
      action: action,
      details: details,
      created_at: Time.current
    )
  end
end

module Security
  class GdprService
    def self.anonymize_old_records(older_than: 2.years)
      # TODO: Implement actual anonymization logic
      Rails.logger.info "Anonymizing records older than #{older_than}"
    end

    def self.delete_expired_data(older_than: 5.years)
      # TODO: Implement deletion logic
      Rails.logger.info "Deleting expired data older than #{older_than}"
    end
  end
end
