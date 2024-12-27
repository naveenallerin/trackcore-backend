class ExternalApprovalAdapter
  def initialize(config = {})
    @api_endpoint = config[:api_endpoint] || ENV['EXTERNAL_APPROVAL_API']
    @api_key = config[:api_key] || ENV['EXTERNAL_APPROVAL_API_KEY']
  end

  def create_approval_request(requisition)
    response = HTTP.auth(@api_key)
                   .post("#{@api_endpoint}/approvals", 
                     json: {
                       requisition_id: requisition.id,
                       callback_url: callback_url(requisition),
                       metadata: build_metadata(requisition)
                     })
    
    handle_response(response)
  end

  def check_status(external_approval_id)
    response = HTTP.auth(@api_key)
                   .get("#{@api_endpoint}/approvals/#{external_approval_id}")
    
    handle_response(response)
  end

  private

  def callback_url(requisition)
    Rails.application.routes.url_helpers
         .api_v1_requisition_approval_complete_url(requisition)
  end

  def build_metadata(requisition)
    {
      title: requisition.title,
      department: requisition.department.name,
      requested_by: requisition.user.email
    }
  end

  def handle_response(response)
    return JSON.parse(response.body.to_s) if response.status.success?
    
    raise ExternalApprovalError, "API Error: #{response.status} - #{response.body}"
  end
end

class ExternalApprovalError < StandardError; end

