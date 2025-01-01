class CreateBrandTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :brand_templates do |t|
      t.string :name, null: false
      t.text :content, null: false
      t.boolean :active, default: true
      t.string :template_type
      t.jsonb :metadata, default: {}
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :brand_templates, :name, unique: true
    add_index :brand_templates, :active
    add_index :brand_templates, :template_type
  end
end
