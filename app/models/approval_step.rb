class ApprovalStep < ApplicationRecord
  belongs_to :approval_request

  validates :approval_request_id, :step_name, presence: true
end
