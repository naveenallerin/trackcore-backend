class CreateJobBoardCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :job_board_credentials do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :api_key, null: false
      t.string :api_secret
      t.json :additional_settings
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :job_board_credentials, [:organization_id, :provider], unique: true
  end
end
