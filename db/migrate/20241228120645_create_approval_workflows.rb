class CreateApprovalWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_workflows do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.text :description
      
      t.timestamps
    end
  end
end
