class CreateApprovalSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_steps do |t|
      t.references :approval_request, null: false, foreign_key: true
      t.string :step_name, null: false
      t.integer :order_index
      t.string :status, default: 'pending'
      t.text :comment
      t.datetime :completed_at

      t.timestamps
    end
  end
end
