class CreateApprovalRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_requests do |t|

      t.timestamps
    end
  end
end
