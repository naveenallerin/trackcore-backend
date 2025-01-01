class Application < ApplicationRecord
  belongs_to :candidate
  belongs_to :requisition
  
  validates :status, presence: true, inclusion: { in: %w[new pending_review reviewed rejected] }
  
  scope :pending_review, -> { where(status: 'pending_review') }
end
