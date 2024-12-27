class RequisitionSerializer

  include FastJsonapi::ObjectSerializer
  
  attributes :title, :department, :description, :status, :created_at, :updated_at
  
  attribute :custom_fields do |object|
    object.requisition_fields.map do |field|
      {
        key: field.field_key,
        value: field.field_value,
        type: field.field_type,
        required: field.required
      }
    end
  end

  attribute :approval_status do |object|
    object.approval_request&.status
  end
end
