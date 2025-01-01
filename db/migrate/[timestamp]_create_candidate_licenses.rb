class CreateCandidateLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :candidate_licenses do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :license_type, null: false, foreign_key: true
      t.string :license_number, null: false
      t.date :issue_date, null: false
      t.date :expiration_date
      t.string :status, default: 'active'

      t.timestamps
    end
    
    add_index :candidate_licenses, [:candidate_id, :license_type_id], unique: true
    add_index :candidate_licenses, :license_number
  end
end
