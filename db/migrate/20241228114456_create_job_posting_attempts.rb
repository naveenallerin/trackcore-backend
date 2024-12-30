class CreateJobPostingAttempts < ActiveRecord::Migration[7.0]
  def change
    create_table :job_posting_attempts do |t|

      t.timestamps
    end
  end
end
