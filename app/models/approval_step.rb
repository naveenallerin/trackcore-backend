class ApprovalStep < ApplicationRecord
  belongs_to :requisition, touch: true
  belongs_to :approver, class_name: 'User'
  
  validates :sequence, presence: true, uniqueness: { scope: :requisition_id }
  validates :status, presence: true
  
  enum status: {
    pending: 0,
    approved: 1,
    rejected: 2,
    skipped: 3
  }
  
  after_update :process_next_step, if: :saved_change_to_status?
  
  private
  
  def process_next_step
    return unless approved?
    next_step = requisition.approval_steps.find_by(sequence: sequence + 1)
    next_step&.update(status: :pending)
  end
end
