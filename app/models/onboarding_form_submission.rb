class CreateOnboardingFormSubmissions < ActiveRecord::Migration[6.1]
    def change
        create_table :onboarding_form_submissions do |t|
            t.string :name
            t.string :email
            t.text :form_data

            t.timestamps
        end
    end
end