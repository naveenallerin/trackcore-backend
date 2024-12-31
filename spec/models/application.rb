class Application < ApplicationRecord
  belongs_to :candidate
  belongs_to :requisition

  enum application_status: {
    applied: 0,
    screened: 1,
    interviewed: 2,
    offered: 3,
    hired: 4,
    rejected: 5
  }

  validates :candidate_id, presence: true
  validates :requisition_id, presence: true
  validates :candidate_id, uniqueness: { scope: :requisition_id,
    message: "has already applied to this requisition" }
  validates :application_status, presence: true

  # Set default status
  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.application_status ||= :applied
  end
end