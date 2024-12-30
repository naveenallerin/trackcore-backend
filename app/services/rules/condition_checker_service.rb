module Rules
  class ConditionCheckerService
    def evaluate(requisition)
      return [] unless requisition

      # Here you would implement your condition checking logic
      # Return an array of actions based on the conditions met
      actions = []
      
      # Example condition check (implement your specific rules here)
      if requisition.amount > 10000
        actions << :require_senior_approval
      end

      if requisition.department == "IT"
        actions << :notify_it_manager
      end

      actions
    end
  end
end
