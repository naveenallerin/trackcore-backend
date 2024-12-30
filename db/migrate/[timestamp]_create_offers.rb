class CreateOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :offers do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :offer_template, null: false, foreign_key: true
      t.string :status, default: 'draft'
      t.integer :version, default: 1
      t.decimal :base_salary, precision: 10, scale: 2
      t.jsonb :compensation_details
      t.string :esign_status
      t.string :esign_document_id
      t.string :signed_document_url
      t.datetime :expires_at
      t.datetime :accepted_at
      t.datetime :declined_at
      t.timestamps
    end

    add_index :offers, :status
    add_index :offers, :esign_status
  end
end
