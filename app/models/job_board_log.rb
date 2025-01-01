class JobBoardLog < ApplicationRecord
  belongs_to :requisition

  validates :requisition_id, presence: true
  validates :board_name, presence: true
  validates :status, presence: true
  validates :response_code, presence: true
  validates :response_message, presence: true

  scope :successful, -> { where(status: 'success') }
  scope :failed, -> { where(status: 'failure') }
end
