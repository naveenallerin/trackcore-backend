class CreateWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :workflows do |t|
      t.string :name
      t.string :workflow_type
      t.jsonb :conditions
      t.boolean :active, default: true
      t.timestamps
    end

    create_table :workflow_steps do |t|
      t.references :workflow, foreign_key: true
      t.string :approver_type
      t.integer :sequence
      t.jsonb :conditions
      t.integer :timeout_hours
      t.string :escalation_strategy
      t.timestamps
    end

    add_index :workflows, [:workflow_type, :active]
    add_index :workflow_steps, [:workflow_id, :sequence]
  end
end
