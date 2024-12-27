class RequisitionSerializer
  include JSONAPI::Serializer

  attributes :title, :description, :status, :created_at, :updated_at
  
  belongs_to :department
  has_many :requisition_fields

  attribute :custom_fields do |object|
    object.requisition_fields.map do |field|
      {
        name: field.name,
        field_type: field.field_type,
        value: field.value
      }
    end
  end
end
