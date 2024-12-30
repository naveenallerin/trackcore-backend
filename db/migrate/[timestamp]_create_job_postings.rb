class CreateJobPostings < ActiveRecord::Migration[7.0]
  def change
    create_table :job_postings do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :board_name, null: false
      t.string :status, null: false, default: "pending"
      t.string :external_reference_id
      t.timestamps

      t.index :board_name
      t.index :status
    end
  end
end
