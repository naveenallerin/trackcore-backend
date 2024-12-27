module Requisitions
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        requisition = Requisition.create!(requisition_params)
        create_custom_fields(requisition)
        requisition
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

