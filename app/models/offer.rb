class Offer < ApplicationRecord
  belongs_to :requisition
  belongs_to :candidate
  belongs_to :created_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true

  validates :base_salary, presence: true, 
    numericality: { greater_than: 0 }
  validates :start_date, presence: true
  validates :expiration_date, presence: true
  validate :expiration_date_after_today
  validate :start_date_after_today
  validates :title, presence: true
  validates :salary, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending accepted rejected withdrawn] }

  enum status: {
    draft: 0,
    pending_approval: 1,
    approved: 2,
    sent: 3,
    accepted: 4,
    declined: 5,
    expired: 6,
    pending: 'pending',
    accepted: 'accepted',
    rejected: 'rejected'
  }

  scope :active, -> { where(status: [:pending_approval, :approved, :sent]) }
  scope :pending_response, -> { where(status: :sent) }
  scope :accepted_this_month, -> { 
    where(status: :accepted)
    .where('accepted_at >= ?', Time.current.beginning_of_month) 
  }
  scope :accepted, -> { where(status: 'accepted') }

  before_save :calculate_total_compensation
  after_create :notify_approvers
  after_update :track_status_change, if: :saved_change_to_status?

  def total_compensation
    base_salary + (bonus || 0)
  end

  def mark_as_accepted!
    return false unless can_be_accepted?
    
    transaction do
      update!(
        status: :accepted,
        accepted_at: Time.current
      )
      requisition.update!(status: :filled)
    end
  end

  private

  def expiration_date_after_today
    return unless expiration_date
    
    if expiration_date < Date.current
      errors.add(:expiration_date, "must be after today")
    end
  end

  def start_date_after_today
    return unless start_date
    
    if start_date < Date.current
      errors.add(:start_date, "must be after today")
    end
  end

  def can_be_accepted?
    sent? && !expired? && expiration_date >= Date.current
  end

  def calculate_total_compensation
    self.metadata ||= {}
    self.metadata['total_compensation'] = total_compensation
  end

  def notify_approvers
    OfferApprovalNotificationJob.perform_async(id) if pending_approval?
  end

  def track_status_change
    OfferStatusChangeJob.perform_async(
      id, 
      status_before_last_save,
      status
    )
  end
end
