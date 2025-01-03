class CreateOnboardingForms < ActiveRecord::Migration[7.0]
    def change
        create_table :onboarding_forms do |t|
            t.string :form_type
            t.jsonb :form_data
            t.string :status
            t.references :user, null: false, foreign_key: true
            t.references :company, null: false, foreign_key: true

            t.timestamps
        end

        add_index :onboarding_forms, :status
        add_index :onboarding_forms, :form_type
    end
end