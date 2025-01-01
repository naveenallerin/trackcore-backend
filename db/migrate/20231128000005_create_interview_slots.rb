class CreateInterviewSlots < ActiveRecord::Migration[7.0]
  def change
    create_table :interview_slots do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.boolean :available, default: true
      t.references :candidate, null: true
      t.timestamps
    end

    add_index :interview_slots, :start_time
    add_index :interview_slots, :available
  end
end
