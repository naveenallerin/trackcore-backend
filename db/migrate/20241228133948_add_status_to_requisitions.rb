class AddStatusToRequisitions < ActiveRecord::Migration[7.0]
  def change
    # Remove this migration since the column already exists
    # If you need to modify the existing status column, use:
    # change_column :requisitions, :status, :string, [your options]
  end
end
