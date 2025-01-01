class CreateCandidates < ActiveRecord::Migration[7.0]
  def change
    create_table :candidates do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.text :address
      t.string :resume_url
      t.datetime :last_activity_at
      t.timestamps
    end

    add_index :candidates, :email, unique: true
    add_index :candidates, :last_activity_at
  end
end
