class CloneRequisitionService
  def self.clone(requisition)
    new_requisition = requisition.dup
    new_requisition.title = "Copy of #{requisition.title}"
    new_requisition.status = 'draft'
    new_requisition.approval_state = 'pending'
    
    ActiveRecord::Base.transaction do
      new_requisition.save!
      
      # Clone custom fields
      requisition.requisition_fields.each do |field|
        new_requisition.requisition_fields.create!(
          field_name: field.field_name,
          field_type: field.field_type,
          field_value: field.field_value
        )
      end

      # Clone job postings if any
      requisition.job_postings.each do |posting|
        new_requisition.job_postings.create!(
          board_name: posting.board_name,
          status: 'draft'
        )
      end

      new_requisition
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ServiceError, "Failed to clone requisition: #{e.message}"
  end
end
