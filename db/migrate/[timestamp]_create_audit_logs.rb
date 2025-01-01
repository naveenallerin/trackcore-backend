class AuditLog < ApplicationRecord
  validates :event_type, :occurred_at, presence: true
  
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :target, polymorphic: true, optional: true

  scope :recent, -> { order(occurred_at: :desc) }
  scope :by_event, ->(type) { where(event_type: type) }
end