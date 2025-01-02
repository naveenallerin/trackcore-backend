class AddPipelineReferenceToCandidates < ActiveRecord::Migration[7.0]
  def change
    add_reference :candidates, :pipeline_stage, null: false, foreign_key: true
  end
end
