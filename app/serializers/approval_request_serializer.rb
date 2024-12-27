class ApprovalRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :created_at, :updated_at
  
  belongs_to :approver
  belongs_to :requisition
end
