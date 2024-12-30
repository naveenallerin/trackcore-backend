class CreateOfferTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :offer_templates do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :version, default: 1
      t.references :approved_by, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.string :locale, default: 'en'
      t.jsonschema :placeholder_schema
      t.timestamps
    end

    add_index :offer_templates, [:title, :version], unique: true
  end
end
