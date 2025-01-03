class CreateOnboardingTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :onboarding_tasks do |t|
      t.references :candidate, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :due_date, null: false
      t.string :status, default: 'pending'
      t.string :task_type
      t.string :form_identifier
      t.timestamps
    end

    add_index :onboarding_tasks, [:candidate_id, :status]
    add_index :onboarding_tasks, :due_date
  end
end
