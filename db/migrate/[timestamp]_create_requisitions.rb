class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.string :department, null: false
      t.text :description
      t.string :status, default: 'draft'
      t.jsonb :metadata, default: {}
      t.datetime :published_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :requisitions, :status
    add_index :requisitions, :department
  end
end
