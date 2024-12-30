class CreateJobBoardCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :job_board_credentials do |t|

      t.timestamps
    end
  end
end
