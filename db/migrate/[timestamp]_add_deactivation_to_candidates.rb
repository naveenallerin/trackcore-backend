class AddDeactivationToCandidates < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :active, :boolean, default: true, null: false
    add_column :candidates, :deactivated_at, :datetime
    add_column :candidates, :deactivated_by_id, :bigint
    add_column :candidates, :deactivation_reason, :string

    add_index :candidates, :active
    add_index :candidates, :deactivated_at
    add_index :candidates, :deactivated_by_id

    add_foreign_key :candidates, :users, column: :deactivated_by_id
  end
end
