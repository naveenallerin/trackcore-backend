class CreateCandidateStageLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :candidate_stage_logs do |t|
      t.references :candidate, null: false, foreign_key: true
      t.references :requisition, null: false, foreign_key: true
      t.string :stage
      t.datetime :entered_at
      t.datetime :exited_at
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :candidate_stage_logs, [:candidate_id, :stage]
    add_index :candidate_stage_logs, :entered_at
  end
end
