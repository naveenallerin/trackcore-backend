class CreateInterviews < ActiveRecord::Migration[7.0]
  def change
    create_table :interviews do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.string :location_or_link
      t.string :status, default: 'scheduled'
      t.timestamps
    end
  end
end
