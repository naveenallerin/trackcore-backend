class CreateResourceFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :resource_feedbacks do |t|
      t.references :resource, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating
      t.text :comment
      t.timestamps
    end

    add_index :resource_feedbacks, [:resource_id, :user_id], unique: true
  end
end
