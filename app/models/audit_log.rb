class AuditLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true
  validates :candidate_ids, presence: true

  scope :bulk_updates, -> { where(action: 'bulk_update') }
end
