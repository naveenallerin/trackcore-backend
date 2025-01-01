class AddDuplicateDetectionIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :candidates, :email
    add_index :candidates, :phone
    add_index :candidates, :first_name, using: :gist, opclass: :gist_trgm_ops
    add_index :candidates, :last_name, using: :gist, opclass: :gist_trgm_ops
    add_index :candidates, :location, using: :gist, opclass: :gist_trgm_ops
  end
end
