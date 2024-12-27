class RequisitionService
  def self.create(params)
    requisition = Requisition.new(
      title: params[:title],
      description: params[:description],
      department_id: params[:department_id]
    )
    
    if requisition.save
      create_custom_fields(requisition, params[:custom_fields])
      { success: true, requisition: requisition }
    else
      { success: false, errors: requisition.errors }
    end
  end

  private

  def self.create_custom_fields(requisition, custom_fields)
    return unless custom_fields

    custom_fields.each do |field|
      requisition.requisition_fields.create(
        name: field[:name],
        field_type: field[:field_type],
        value: field[:value]
      )
    end
  end
end
