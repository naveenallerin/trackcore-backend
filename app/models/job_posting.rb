class JobPosting < ApplicationRecord
  belongs_to :requisition

  enum status: {
    pending: "pending",
    posted: "posted",
    failed: "failed",
    removed: "removed"
  }

  validates :board_name, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
end
