class ApprovalWorkflow < ApplicationRecord
  belongs_to :organization
  has_many :approval_requests
end
