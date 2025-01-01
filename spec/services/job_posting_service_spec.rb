require 'rails_helper'

RSpec.describe JobPostingService do
  let(:job_data) do
    double(
      title: 'Software Engineer',
      description: 'Amazing job opportunity',
      location: 'Remote',
      company_name: 'Tech Corp',
      salary_range: '$100k-$150k'
    )
  end

  let(:service) { described_class.new(job_data) }

  describe '#post_to_all' do
    before do
      stub_request(:post, ENV['INDEED_API_ENDPOINT'])
        .to_return(status: 200, body: { id: '123' }.to_json)
      
      stub_request(:post, ENV['LINKEDIN_API_ENDPOINT'])
        .to_return(status: 200, body: { posting_id: '456' }.to_json)
      
      stub_request(:post, ENV['GLASSDOOR_API_ENDPOINT'])
        .to_return(status: 200, body: { job_id: '789' }.to_json)
    end

    it 'posts to all job boards' do
      results = service.post_to_all

      expect(results[:indeed][:success]).to be true
      expect(results[:linkedin][:success]).to be true
      expect(results[:glassdoor][:success]).to be true
    end

    context 'when a job board fails' do
      before do
        stub_request(:post, ENV['INDEED_API_ENDPOINT'])
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'continues posting to other boards' do
        results = service.post_to_all

        expect(results[:indeed][:success]).to be false
        expect(results[:linkedin][:success]).to be true
        expect(results[:glassdoor][:success]).to be true
      end
    end
  end
end
