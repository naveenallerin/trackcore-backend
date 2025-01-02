class CreateCandidateCommunicationPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :candidate_communication_preferences do |t|
      t.references :candidate, null: false, foreign_key: true, index: true
      t.string :channel, null: false
      t.boolean :opt_in, null: false, default: true
      t.string :phone_number
      t.timestamps
    end

    add_index :candidate_communication_preferences, [:candidate_id, :channel], 
              unique: true, 
              name: 'index_candidate_comm_prefs_on_candidate_id_and_channel'
  end
end
