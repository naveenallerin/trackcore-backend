class RequisitionSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :created_at, :updated_at
  
  belongs_to :department
  has_many :requisition_fields
  has_many :status_changes
  
  def requisition_fields
    object.requisition_fields.active
  end
end
