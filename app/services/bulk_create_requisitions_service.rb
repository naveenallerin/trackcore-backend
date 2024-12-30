class BulkCreateRequisitionsService
  def self.create(requisitions_params, user)
    results = { success: [], errors: [] }
    
    ActiveRecord::Base.transaction do
      requisitions_params.each do |params|
        requisition = Requisition.new(params.merge(user: user))
        
        if requisition.save
          results[:success] << requisition
          
          # Handle job board posting if requested
          if params[:post_to_boards].present?
            params[:post_to_boards].each do |board|
              PostToJobBoardJob.perform_later(
                requisition_id: requisition.id,
                board_name: board
              )
            end
          end
        else
          results[:errors] << { 
            params: params, 
            errors: requisition.errors.full_messages 
          }
        end
      end
    end
    
    results
  rescue StandardError => e
    raise ServiceError, "Bulk creation failed: #{e.message}"
  end
end
