class CreateApprovalDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_decisions do |t|

      t.timestamps
    end
  end
end
