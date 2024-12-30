class CreateApprovalSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_steps do |t|

      t.timestamps
    end
  end
end
