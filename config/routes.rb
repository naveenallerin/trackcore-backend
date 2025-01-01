# config/routes.rb

require 'sidekiq/web'

Rails.application.routes.draw do
  # Place root route at the top for priority
  root 'home#index'
  
  # Keep only necessary routes for test environment
  if Rails.env.test?
    get '/health', to: 'health#show'
  else
    post '/login', to: 'auth#login'
    post '/signup', to: 'auth#signup'
    
    resources :candidates, only: [:index, :show, :create, :update, :destroy]

    namespace :api do
      namespace :v1 do
        get 'dashboard', to: 'dashboard#index'
        resources :candidates do
          collection do
            post :bulk_update
            post :merge
          end
          member do
            post :knockout_check
            patch :override_score
            get :check_duplicates

            patch :archive
            post :upload_resume
          end
          resources :licenses, controller: 'candidate_licenses' do
            member do
              post :verify
            end
          end
        end
        resources :candidates do
          resources :notes, only: [:index, :create, :update, :destroy]
          resources :interviews, only: [:index, :create]
        end
        resources :requisitions do
          member do
            post :clone
            post :submit
            post :request_approval
            post :approval_complete
            get :approval_status
            resources :comments, only: [:index, :create]
            resources :attachments, only: [:index, :create, :destroy]
            post :post_to_boards
            post :ai_generate_description
          end
          collection do
            post :bulk_create
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
            post :enhance
            post :approve
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

        resources :dashboards, only: [:index] do
          collection do
            get :metrics
            get :widgets
            get :drill_down
          end
        end

        resources :approvals, only: [] do
          resources :steps, only: [], controller: 'approvals' do
            member do
              patch :approve, action: :approve_step
              patch :reject, action: :reject_step
            end
          end
        end

        resources :job_postings, only: [:create, :destroy]

        resources :rules

        resource :dashboard, only: [:show] do
          get :drill_down, on: :member
          resources :widgets, only: [:index, :create, :destroy] do
            collection do
              put :reorder
            end
          end
        end

        resource :dashboard_layout, only: [:show, :update]

        resources :widgets, only: [] do
          collection do
            get :available
            get :categories
          end
        end

        namespace :admin do
          resources :widget_definitions, except: [:show]
          resources :widgets, except: [:index, :show]
        end

        namespace :webhooks do
          post 'sms/inbound', to: 'sms#inbound'
        end

        post 'webhooks/:provider', to: 'webhooks#job_board_update'

        get 'dashboard/metrics', to: 'dashboards#metrics'
        get 'dashboard/health', to: 'dashboards#health_status'

        namespace :candidate_portal do
          post 'login', to: 'auth#create'
          resource :profile, only: [:show, :update] do
            post :upload_resume
          end
          resources :documents, only: [:index, :show, :update]
          resources :job_recommendations, only: [:index]
        end

        resources :interviews do
          member do
            get :recording

            get :transcript
          end
        end

        namespace :preboarding do
          resources :contents do
            member do
              post :progress
            end
          end

          resources :quizzes do
            member do
              post :attempt
            end
          end

          get 'dashboard', to: 'analytics#dashboard'
        end

        resources :trend_analysis, only: [] do
          collection do
            get :historical_metrics
            get :forecast
          end
        end

        resources :notifications, only: [:index, :update] do
          collection do
            post :mark_all_read
          end
        end

        resources :onboarding_tasks do
          member do
            put :complete
          end
          resources :document_uploads, only: [:create, :destroy] do
            member do
              put :verify
              put :reject
            end
          end
        end

        # Analytics routes
        get 'analytics', to: 'analytics#index'
        get 'analytics/time_to_fill', to: 'analytics#time_to_fill'
        get 'analytics/cost_per_hire', to: 'analytics#cost_per_hire'
        get 'analytics/diversity_metrics', to: 'analytics#diversity_metrics'

        # Workflow rules
        resources :workflow_rules do
          member do
            post :activate
            post :deactivate
          end
        end

      end
    end

    # Temporary direct mount without authentication
    mount Sidekiq::Web => '/sidekiq'

    # Monitoring endpoints
    get '/metrics' => 'monitoring#metrics'

    resources :candidates do
      resources :interviews, only: [:index, :create]
    end
    resources :interviews, only: [:show, :update, :destroy]

    resources :interviews
    resources :offers do
      member do
        put :accept
        put :reject
      end
    end

    resources :brand_templates do
      member do
        get :versions
      end
      collection do
        get :active
      end
    end
  end
end