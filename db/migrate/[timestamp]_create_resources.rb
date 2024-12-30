class CreateResources < ActiveRecord::Migration[7.0]
  def change
    create_table :resources do |t|
      t.string :title, null: false
      t.string :category, null: false
      t.text :body_html
      t.string :file_url
      t.string :status, default: 'active'
      t.string :region_restriction
      t.integer :version, default: 1
      t.jsonb :version_history, default: {}
      t.timestamps
    end

    add_index :resources, :category
    add_index :resources, :status
  end
end
