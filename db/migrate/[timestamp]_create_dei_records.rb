class CreateDeiRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :dei_records do |t|
      t.references :candidate, null: false, foreign_key: true
      t.string :gender
      t.string :ethnicity
      t.string :disability_status
      t.string :veteran_status
      
      # Add timestamps for record keeping
      t.timestamps
    end

    # Add index for faster querying
    add_index :dei_records, [:gender, :ethnicity, :disability_status, :veteran_status], 
              name: 'index_dei_records_on_demographic_fields'
  end
end
