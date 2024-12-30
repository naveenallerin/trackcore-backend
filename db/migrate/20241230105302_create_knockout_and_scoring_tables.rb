class CreateKnockoutAndScoringTables < ActiveRecord::Migration[7.0]
  def change
    create_table :knockout_and_scoring_tables do |t|

      t.timestamps
    end
  end
end
