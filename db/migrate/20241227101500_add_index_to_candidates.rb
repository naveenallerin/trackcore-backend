class AddIndexToCandidates < ActiveRecord::Migration[7.0]
  def change
    add_index :candidates, :email, unique: true
  end
end
