class AddStatusToRequisitions < ActiveRecord::Migration[7.0]
  def change
    add_column :requisitions, :status, :integer, default: 0, null: false
    add_column :requisitions, :cfo_approved, :boolean, default: false
  end
end
