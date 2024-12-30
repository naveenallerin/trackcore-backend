class CreateCandidates < ActiveRecord::Migration[7.0]
  def change
    create_table :candidates do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :status, default: 'new'
      t.text :notes
      t.jsonb :metadata
      
      t.timestamps
    end
    
    add_index :candidates, :email, unique: true
    add_index :candidates, :status
  end
end
