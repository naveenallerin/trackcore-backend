module Api
  module V1
    class PostingsController < ApplicationController
      def create
        posting = Posting.new(posting_params)
        
        if posting.save
          render json: PostingSerializer.new(posting), status: :created
        else
          render json: { errors: posting.errors }, status: :unprocessable_entity
        end
      end

      private

      def posting_params
        params.require(:posting).permit(:title, :description, :requirements, :requisition_id)
      end
    end
  end
end
