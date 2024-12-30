class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'pending'
      t.string :approval_state, default: 'pending'
      t.references :user, foreign_key: true
      
      t.timestamps
    end
  end
end
