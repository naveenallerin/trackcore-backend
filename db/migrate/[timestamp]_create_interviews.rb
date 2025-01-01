class CreateInterviews < ActiveRecord::Migration[7.0]
  def change
    create_table :interviews do |t|
      t.references :candidate, null: false, foreign_key: true, index: true
      t.datetime :scheduled_at, null: false
      t.string :location
      t.references :interviewer, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
