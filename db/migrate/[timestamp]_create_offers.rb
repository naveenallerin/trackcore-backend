class CreateOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :offers do |t|
      t.references :requisition, null: false, foreign_key: true
      t.references :candidate, null: false, foreign_key: true, index: true
      t.integer :status, default: 0
      t.decimal :base_salary, precision: 12, scale: 2
      t.decimal :bonus, precision: 12, scale: 2
      t.json :benefits
      t.date :start_date
      t.date :expiration_date
      t.datetime :accepted_at
      t.datetime :declined_at
      t.text :decline_reason
      t.string :offer_letter_url
      t.text :notes
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.json :metadata
      t.string :title, null: false
      t.decimal :salary, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :offers, :status
    add_index :offers, :start_date
    add_index :offers, [:requisition_id, :candidate_id]
  end
end
