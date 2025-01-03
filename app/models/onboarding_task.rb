class OnboardingTask < ApplicationRecord
  belongs_to :candidate

  validates :title, presence: true
  validates :due_date, presence: true
  validates :status, inclusion: { in: %w[pending complete overdue] }

  scope :pending, -> { where(status: 'pending') }
  scope :overdue, -> { where('due_date < ? AND status = ?', Date.current, 'pending') }
  scope :due_soon, -> { where('due_date BETWEEN ? AND ? AND status = ?', 
                             Date.current, 3.days.from_now, 'pending') }

  def mark_as_complete!
    update!(status: 'complete')
  end

  def mark_as_overdue!
    update!(status: 'overdue')
  end
end
