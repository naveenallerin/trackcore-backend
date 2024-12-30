module Api
  module V1
    class ResourcesController < ApplicationController
      before_action :set_resource, only: [:show, :update, :destroy, :revert_version]

      def index
        @resources = Resource.active
          .by_category(params[:category])
          .by_region(current_user.region)
        
        render json: @resources
      end

      def show
        authorize @resource
        render json: @resource
      end

      def create
        @resource = Resource.new(resource_params)
        
        if @resource.save
          render json: @resource, status: :created
        else
          render json: @resource.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize @resource
        
        if @resource.update(resource_params)
          @resource.increment_version!
          render json: @resource
        else
          render json: @resource.errors, status: :unprocessable_entity
        end
      end

      def revert_version
        authorize @resource
        
        if @resource.revert_to_version!(params[:version])
          render json: @resource
        else
          render json: { error: 'Version not found' }, status: :not_found
        end
      end

      private

      def set_resource
        @resource = Resource.find(params[:id])
      end

      def resource_params
        params.require(:resource).permit(:title, :category, :body_html, 
                                       :file_url, :status, :region_restriction)
      end
    end
  end
end
