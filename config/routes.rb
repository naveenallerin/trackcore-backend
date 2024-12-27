# config/routes.rb

Rails.application.routes.draw do
  resources :candidates, only: [:index, :show, :create, :update, :destroy]

  namespace :api do
    namespace :v1 do
      resources :candidates
    end
  end

  # Monitoring endpoints
  get '/metrics' => 'monitoring#metrics'

  # Health check endpoint
  get '/health', to: 'health#show'

  # root "posts#index"  # optional
end