require 'rails_helper'

RSpec.describe BulkCreateRequisitionsService do
  describe '.create' do
    let(:user) { create(:user) }
    let(:valid_params) do
      [
        { title: 'First Req', description: 'Description 1' },
        { title: 'Second Req', description: 'Description 2' }
      ]
    end

    it 'creates multiple requisitions' do
      results = BulkCreateRequisitionsService.create(valid_params, user)
      
      expect(results[:success].length).to eq(2)
      expect(results[:errors]).to be_empty
    end

    context 'with job board posting' do
      let(:params_with_boards) do
        [{
          title: 'Dev Position',
          description: 'Ruby dev',
          post_to_boards: ['linkedin', 'indeed']
        }]
      end

      it 'enqueues posting jobs for specified boards' do
        expect {
          BulkCreateRequisitionsService.create(params_with_boards, user)
        }.to have_enqueued_job(PostToJobBoardJob).twice
      end
    end

    context 'with invalid data' do
      let(:invalid_params) do
        [
          { title: '' },  # Invalid - missing title
          { title: 'Valid Req' }  # Valid
        ]
      end

      it 'captures errors and continues processing' do
        results = BulkCreateRequisitionsService.create(invalid_params, user)
        
        expect(results[:success].length).to eq(1)
        expect(results[:errors].length).to eq(1)
        expect(results[:errors].first[:errors]).to include("Title can't be blank")
      end
    end

    context 'when database transaction fails' do
      before do
        allow(Requisition).to receive(:new).and_raise(ActiveRecord::StatementInvalid)
      end

      it 'raises a ServiceError' do
        expect {
          BulkCreateRequisitionsService.create(valid_params, user)
        }.to raise_error(ServiceError)
      end
    end
  end
end
