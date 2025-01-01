class ApprovalFlow < ApplicationRecord
  belongs_to :requisition

  validates :role, presence: true
  validates :sequence, presence: true
  validates :role, uniqueness: { scope: :requisition_id }

  enum status: { pending: 0, approved: 1, rejected: 2 }
  
  APPROVAL_ROLES = %w[CFO HR DepartmentHead Finance].freeze

  validates :role, inclusion: { in: APPROVAL_ROLES }

  def needs_approval?
    return true if condition_threshold.nil?
    requisition.salary.to_d >= condition_threshold
  end

  def can_approve?(user)
    user.has_role?(role) && pending?
  end

  def approve!(user)
    return false unless can_approve?(user)
    
    transaction do
      update!(status: :approved)
      requisition.check_approval_completion
    end
  end

  private

  def validate_threshold
    return unless condition_threshold.present?
    errors.add(:condition_threshold, "must be positive") if condition_threshold.negative?
  end
end
