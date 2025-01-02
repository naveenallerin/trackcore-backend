
module Candidates
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]

    protected

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [
        :first_name, :last_name, :phone, :location, :primary_skill
      ])
    end

    def after_sign_up_path_for(resource)
      edit_candidate_registration_path
    end

    def after_update_path_for(resource)
      candidate_profile_path
    end
  end
end
