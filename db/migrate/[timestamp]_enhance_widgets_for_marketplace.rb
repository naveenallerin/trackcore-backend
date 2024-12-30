class EnhanceWidgetsForMarketplace < ActiveRecord::Migration[7.0]
  def change
    change_table :widgets do |t|
      t.text :description
      t.string :roles_allowed, array: true, default: []
      t.string :endpoint
      t.string :partial_name
      t.boolean :active, default: true
      t.string :category
    end

    add_index :widgets, :roles_allowed, using: :gin
    add_index :widgets, :active
    add_index :widgets, :category
  end
end
