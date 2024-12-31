class CreateCandidates < ActiveRecord::Migration[7.0]
  def change
    create_table :candidates do |t|
      t.references :job, null: false, foreign_key: true
      t.string :status, null: false, default: 'new'
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :resume_text
      t.string :resume_url
      t.decimal :ai_score, precision: 5, scale: 2
      t.jsonb :ai_analysis_results
      t.jsonb :skill_matches
      t.text :notes
      t.jsonb :metadata
      
      t.timestamps
    end
    
    add_index :candidates, [:job_id, :email], unique: true
    add_index :candidates, :ai_score
    add_index :candidates, :status
  end
end
