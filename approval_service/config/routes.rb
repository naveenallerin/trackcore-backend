Rails.application.routes.draw do
  # ...existing code...
  
  namespace :api do
    namespace :v1 do
      resources :approvals do
        member do
          patch :complete
        end
      end
    end
  end
  
  # ...existing code...
end
