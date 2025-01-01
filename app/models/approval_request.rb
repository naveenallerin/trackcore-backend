class ApprovalRequest < ApplicationRecord
  # Associations
  belongs_to :approval_workflow
  belongs_to :approvable, polymorphic: true
  belongs_to :approver, class_name: 'User'
  belongs_to :requisition
  has_many :approval_steps, dependent: :destroy

  # Enums
  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }
  validates :approver, presence: true
  validates :requisition_id, presence: true
  validates :requisition, :approval_workflow, :approvable, :approver, presence: true

  # Basic scopes
  scope :pending, -> { where(status: :pending) }
  scope :completed, -> { where(status: [:approved, :rejected]) }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }

  def approve!(comment = nil)
    update!(
      status: :approved,
      comment: comment,
      approved_at: Time.current
    )
  end

  def reject!(comment = nil)
    update!(
      status: :rejected,
      comment: comment,
      rejected_at: Time.current
    )
  end

  # Find the current active step in the approval chain
  def active_step
    approval_steps.find_by(status: 'pending')
  end

  # Find the next step after a given step
  def next_step(current_step)
    approval_steps.where('order_index > ?', current_step.order_index)
                 .order(order_index: :asc)
                 .first
  end

  # Check if all steps are approved
  def all_steps_approved?
    approval_steps.all? { |step| step.approved? }
  end

  # Update request status based on steps
  def update_status!
    if approval_steps.any?(&:rejected?)
      rejected!
    elsif all_steps_approved?
      approved!
    else
      pending!
    end
  end

  private

  def validate_status_transition
    return if status_was.nil?
    return if %w[approved rejected].exclude?(status_was)
    errors.add(:status, 'cannot be changed once finalized')
  end
end
