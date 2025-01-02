class CreateEmailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :email_templates do |t|
      t.string :name, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.string :category
      t.string :department
      t.jsonb :required_placeholders, default: []
      t.text :footer
      t.boolean :active, default: true
      t.boolean :compliance_approved, default: false
      t.string :compliance_version
      t.timestamps

      t.index :name
      t.index :category
      t.index :department
      t.index [:name, :department], unique: true
    end
  end
end
