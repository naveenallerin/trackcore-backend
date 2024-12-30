module Requisitions
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      @requisition = Requisition.new(requisition_params)
      
      if @requisition.save
        TrackcoreCommon::EventPublisher.publish(
          'requisition_created',
          {
            requisition_id: @requisition.id,
            created_at: @requisition.created_at,
            department: @requisition.department
          }
        )
        Success.new(@requisition)
      else
        Failure.new(@requisition.errors)
      end
    end

    private

    def requisition_params
      @params.slice(:title, :department, :description)
    end

    def create_custom_fields(requisition)
      return unless @params[:custom_fields]

      @params[:custom_fields].each do |field|
        requisition.requisition_fields.create!(
          field_name: field[:name],
          field_value: field[:value],
          field_type: field[:type]
        )
      end
    end
  end
end

