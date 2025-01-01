class CreateRequisitions < ActiveRecord::Migration[7.0]
  def change
    create_table :requisitions do |t|
      t.string :job_title, null: false
      t.references :department, null: false, foreign_key: true
      t.text :description
      t.string :status, default: 'draft'
      t.jsonb :metadata, default: {}
      t.datetime :approved_at
      t.datetime :published_at
      t.datetime :closed_at
      t.references :user, foreign_key: true
      
      t.timestamps
    end

    add_index :requisitions, :status
    add_index :requisitions, :metadata, using: :gin
  end
end