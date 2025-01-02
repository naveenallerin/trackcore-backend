class CreatePipelineStages < ActiveRecord::Migration[7.0]
  def change
    create_table :pipeline_stages do |t|
      t.string :name, null: false
      t.integer :position, null: false
      t.references :department, null: true, foreign_key: true
      t.boolean :active, default: true
      
      t.timestamps
    end
    
    add_index :pipeline_stages, [:department_id, :position], unique: true
    add_index :pipeline_stages, [:department_id, :name], unique: true
  end
end
