class CreateRecruitingCosts < ActiveRecord::Migration[7.0]
  def change
    create_table :recruiting_costs do |t|
      t.references :requisition, null: false, foreign_key: true
      t.string :cost_type
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency, default: 'USD'
      t.string :source
      t.date :incurred_on
      t.timestamps
    end

    add_index :recruiting_costs, :cost_type
    add_index :recruiting_costs, :source
  end
end
