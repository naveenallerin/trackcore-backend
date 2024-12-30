class Workflow < ApplicationRecord
  has_many :workflow_steps, -> { order(sequence: :asc) }, dependent: :destroy
  
  WORKFLOW_TYPES = %w[requisition_approval offer_approval candidate_progression].freeze
  
  validates :name, presence: true
  validates :workflow_type, inclusion: { in: WORKFLOW_TYPES }
  
  def matches_context?(context)
    return true if conditions.blank?
    
    WorkflowEngine.new(self).evaluate_conditions(conditions, context)
  end
  
  def next_step_for(context, current_step: nil)
    steps = workflow_steps
    current_index = current_step ? steps.index(current_step) : -1
    
    steps[current_index + 1..]&.find do |step|
      step.matches_context?(context)
    end
  end
end
