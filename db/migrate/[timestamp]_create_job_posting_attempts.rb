class CreateJobPostingAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :job_posting_attempts do |t|
      t.references :job, null: false, foreign_key: true
      t.references :job_board_credential, null: false, foreign_key: true
      t.string :status, null: false
      t.integer :attempt_number, null: false
      t.text :error_message
      t.string :external_job_id
      t.json :response_data

      t.timestamps
    end

    add_index :job_posting_attempts, [:job_id, :job_board_credential_id, :attempt_number]
  end
end
