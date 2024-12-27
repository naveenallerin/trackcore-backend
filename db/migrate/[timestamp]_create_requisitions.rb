class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :status, default: 'pending'
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
