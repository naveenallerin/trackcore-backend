class AuditLog < ApplicationRecord
  belongs_to :user
  
  validates :action, presence: true
  validates :details, presence: true

  scope :recent, -> { order(created_at: :desc).limit(100) }
  scope :sign_ins, -> { where(action: 'sign_in') }

  def self.log_action(user, action, details = {})
    create!(
      user: user,
      action: action,
      details: details.to_json,
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
