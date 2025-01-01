class CreateJobBoardLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :job_board_logs do |t|
      t.integer :requisition_id, null: false
      t.string :board_name, null: false
      t.string :status, null: false
      t.string :response_code, null: false
      t.text :response_message, null: false

      t.timestamps
    end

    add_index :job_board_logs, :requisition_id
  end
end
