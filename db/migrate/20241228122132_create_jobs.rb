class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.references :organization, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
