# config/routes.rb

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :candidates, only: [:index, :show, :create, :update, :destroy]

  namespace :api do
    namespace :v1 do
      resources :candidates
      resources :requisitions do
        member do
          post :clone
          post :submit
          post :request_approval
          post :approval_complete
          get :approval_status
          resources :comments, only: [:index, :create]
          resources :attachments, only: [:index, :create, :destroy]
        end
        resources :job_postings, only: [:index, :create, :destroy]
        resources :requisition_fields, only: [:create, :update, :destroy]
        resources :approval_requests, only: [:create]
      end

      resources :approval_requests, only: [:show, :update] do
        member do
          post :approve
          post :reject
        end
      end

      resources :templates do
        member do
          post :preview
          post :generate_draft
        end
        resources :versions, controller: 'template_versions', only: [:index, :show] do
          collection do
            get :compare
          end
          member do
            post :revert
          end
        end
      end

      resources :dashboards, only: [] do
        collection do
          get :metrics
          get :widgets
        end
      end

      post 'webhooks/:provider', to: 'webhooks#job_board_update'

      get 'dashboard/metrics', to: 'dashboards#metrics'
      get 'dashboard/health', to: 'dashboards#health_status'

    end
  end

  # Temporary direct mount without authentication
  mount Sidekiq::Web => '/sidekiq'

  # Monitoring endpoints
  get '/metrics' => 'monitoring#metrics'

  # Health check endpoint
  get '/health', to: 'health#show'

  # root "posts#index"  # optional
end