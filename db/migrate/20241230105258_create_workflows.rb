class CreateWorkflows < ActiveRecord::Migration[7.0]
  def change
    create_table :workflows do |t|

      t.timestamps
    end
  end
end
