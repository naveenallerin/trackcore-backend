class CreateLicenseTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :license_types do |t|
      t.string :name, null: false
      t.string :issuing_authority
      t.integer :renewal_period

      t.timestamps
    end
    
    add_index :license_types, :name, unique: true
  end
end
