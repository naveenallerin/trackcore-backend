class CreateRequisitionTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :requisition_types do |t|

      t.timestamps
    end
  end
end
