class AddStatusColumnToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :status, :string, :default => 'Pending'
  end
end
