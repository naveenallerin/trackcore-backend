class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :message, null: false
      t.datetime :read_at
      t.references :target, polymorphic: true
      
      t.timestamps
    end
    
    add_index :notifications, [:user_id, :created_at]
  end
end
