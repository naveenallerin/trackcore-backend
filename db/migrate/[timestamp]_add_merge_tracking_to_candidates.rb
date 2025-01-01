class AddMergeTrackingToCandidates < ActiveRecord::Migration[7.0]
  def change
    add_column :candidates, :merged_into_id, :bigint
    add_column :candidates, :merged_at, :datetime
    add_index :candidates, :merged_into_id
    add_foreign_key :candidates, :candidates, column: :merged_into_id
  end
end
