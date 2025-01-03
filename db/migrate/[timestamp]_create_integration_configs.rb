class CreateIntegrationConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :integration_configs do |t|
      t.string :provider, null: false
      t.string :api_key, null: false
      t.string :api_secret
      t.string :webhook_url
      t.jsonb :settings, default: {}
      t.boolean :active, default: true
      t.datetime :last_sync_at
      t.string :status
      t.text :status_message
      t.timestamps

      t.index :provider
      t.index :active
    end

    add_column :job_postings, :external_job_id, :string
    add_index :job_postings, :external_job_id
  end
end
