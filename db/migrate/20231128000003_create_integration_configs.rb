class CreateIntegrationConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :integration_configs do |t|
      t.string :provider_name, null: false
      t.string :api_key
      t.string :api_secret
      t.boolean :active, default: true
      t.datetime :last_sync_at
      t.timestamps
    end

    add_index :integration_configs, :provider_name, unique: true
  end
end
