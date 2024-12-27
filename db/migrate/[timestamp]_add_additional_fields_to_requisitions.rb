class AddAdditionalFieldsToRequisitions < ActiveRecord::Migration[7.0]
  def change
    add_column :requisitions, :salary_range, :string
    add_column :requisitions, :location, :string
    add_column :requisitions, :external_approval_id, :string
    add_column :requisitions, :approval_service, :string
  end
end
