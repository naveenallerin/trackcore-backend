class DropRequisitionFieldsrails < ActiveRecord::Migration[7.0]
  def change
    drop_table :requisition_fieldsrails, if_exists: true
  end
end
