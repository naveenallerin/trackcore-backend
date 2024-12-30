module ServiceMockHelpers
  def mock_approval_service
    stub_request(:post, "#{Requisitions::ApprovalNotifier::APPROVAL_SERVICE_URL}/api/v1/approvals")
      .to_return(
        status: 201,
        body: { id: 1, status: 'pending' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:patch, "#{Requisitions::ApprovalNotifier::APPROVAL_SERVICE_URL}/api/v1/approvals/1/complete")
      .to_return(
        status: 200,
        body: { id: 1, status: 'completed' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def mock_job_posting_service
    stub_request(:post, "#{ENV['JOB_POSTING_SERVICE_URL']}/api/v1/postings")
      .to_return(
        status: 201,
        body: { id: 1, status: 'published' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
