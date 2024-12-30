class ApprovalStep < ApplicationRecord
  belongs_to :approval_request

  validates :approval_request_id, presence: true
  validates :step_name, presence: true
end
