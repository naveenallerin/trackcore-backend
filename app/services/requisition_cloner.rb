class RequisitionCloner
  def self.clone(requisition)
    new(requisition).clone
  end

  def initialize(requisition)
    @requisition = requisition
  end

  def clone
    new_requisition = @requisition.dup
    new_requisition.status = 'draft'
    new_requisition.approved_at = nil
    new_requisition.published_at = nil
    new_requisition.closed_at = nil
    
    ActiveRecord::Base.transaction do
      new_requisition.save!
      clone_associated_records(new_requisition)
      new_requisition
    end
  end

  private

  def clone_associated_records(new_requisition)
    @requisition.requisition_fields.each do |field|
      new_requisition.requisition_fields.create!(
        field.attributes.except('id', 'created_at', 'updated_at', 'requisition_id')
      )
    end
    
    @requisition.approval_steps.each do |step|
      new_requisition.approval_steps.create!(
        step.attributes.except('id', 'created_at', 'updated_at', 'requisition_id', 'status')
      )
    end
  end
end