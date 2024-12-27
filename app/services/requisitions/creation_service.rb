module Requisitions
  class CreationService
    def initialize(params)
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        requisition = Requisition.new(@params.slice(:title, :department, :description))
        
        if @params[:custom_fields].present?
          @params[:custom_fields].each do |field|
            requisition.requisition_fields.build(
              field_key: field[:key],
              field_value: field[:value]
            )
          end
        end

        if requisition.save
          # Trigger approval workflow
          ApprovalService.new(requisition).initiate_workflow
          # Broadcast event
          RequisitionCreatedEvent.broadcast(requisition)
          
          return Success.new(requisition)
        else
          return Failure.new(requisition.errors.full_messages)
        end
      end
    end
  end
end
