class CreateOfferRevisions < ActiveRecord::Migration[7.0]
  def change
    create_table :offer_revisions do |t|
      t.references :offer, null: false, foreign_key: true
      t.integer :version
      t.string :status, default: 'pending'
      t.decimal :base_salary, precision: 10, scale: 2
      t.jsonb :compensation_details
      t.text :candidate_notes
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :offer_revisions, [:offer_id, :version], unique: true
  end
end
