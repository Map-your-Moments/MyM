class RemoveClientApplications < ActiveRecord::Migration
  def up
    drop_table :client_applications
  end

  def down
  end
end
