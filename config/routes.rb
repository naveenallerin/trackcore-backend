# config/routes.rb

Rails.application.routes.draw do
  resources :candidates, only: [:index, :show, :create, :update, :destroy]

  namespace :api do
    namespace :v1 do
      resources :candidates
      resources :requisitions do
        member do
          post :clone
        end
        resources :job_postings, only: [:index, :create, :destroy]
      end

      resources :approval_requests, only: [:show] do
        member do
          post :approve
          post :reject
        end
      end
    end
  end

  # Monitoring endpoints
  get '/metrics' => 'monitoring#metrics'

  # Health check endpoint
  get '/health', to: 'health#show'

  # root "posts#index"  # optional
end