class ApprovalRequest < ApplicationRecord
  belongs_to :requisition
  
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }
  validates :approver_type, presence: true

  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: %w[approved rejected]) }
end
