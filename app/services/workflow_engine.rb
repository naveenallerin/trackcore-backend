class WorkflowEngine
  def initialize(workflow)
    @workflow = workflow
  end

  def start!(context)
    return false unless @workflow.matches_context?(context)
    
    first_step = @workflow.next_step_for(context)
    create_approval_request(first_step, context) if first_step
  end

  def evaluate_conditions(conditions, context)
    conditions.all? do |condition|
      case condition['operator']
      when '>'
        context[condition['field']].to_f > condition['value'].to_f
      when '<'
        context[condition['field']].to_f < condition['value'].to_f
      when 'includes'
        Array(context[condition['field']]).include?(condition['value'])
      else
        context[condition['field']] == condition['value']
      end
    end
  end

  def evaluate_knockout_rules(candidate, rules)
    rules.each do |rule|
      result = evaluate_conditions(rule.conditions, candidate.attributes)
      log = create_knockout_log(candidate, rule, result)
      
      if result && !should_override?(candidate)
        candidate.update(status: 'knocked_out', knockout_reason: rule.name)
        return false
      end
    end
    true
  end

  def calculate_weighted_score(candidate, weights)
    total_score = weights.sum do |field, weight|
      (candidate.send(field) || 0) * weight
    end
    
    ScoreLog.create!(
      candidate: candidate,
      score: total_score,
      weights: weights
    )
    
    candidate.update(current_score: total_score)
    total_score
  end

  private

  def create_approval_request(step, context)
    ApprovalRequest.create!(
      workflow_step: step,
      context: context,
      due_at: step.timeout_hours&.hours&.from_now
    )
  end

  def should_override?(candidate)
    return false unless candidate.override_requested?
    candidate.override_approvals.exists?(status: 'approved')
  end

  def create_knockout_log(candidate, rule, result)
    KnockoutLog.create!(
      candidate: candidate,
      knockout_rule: rule,
      result: result ? 'knocked_out' : 'passed',
      context: candidate.attributes
    )
  end
end
