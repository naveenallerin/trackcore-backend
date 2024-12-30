class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'draft'
      t.references :department, foreign_key: true
      t.references :organization, foreign_key: true
      t.jsonb :requirements
      t.jsonb :metadata

      t.timestamps
    end
    
    add_index :jobs, :status
  end
end
