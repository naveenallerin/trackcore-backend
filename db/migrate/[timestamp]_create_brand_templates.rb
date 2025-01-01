class CreateBrandTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :brand_templates do |t|
      t.string :brand_name, null: false
      t.text :template_html
      t.string :brand_logo_url
      t.string :brand_color
      t.jsonb :template_variables, default: {}
      t.references :company, foreign_key: true
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :brand_templates, :brand_name
    add_index :brand_templates, [:company_id, :brand_name], unique: true
  end
end
