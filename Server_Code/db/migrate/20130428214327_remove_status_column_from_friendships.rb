class RemoveStatusColumnFromFriendships < ActiveRecord::Migration
  def up
    remove_column :friendships, :status
    add_column :friendships, :type, :string, :default => 'PendingFriendship'
  end

  def down
    add_column :friendships, :status, :string
  end
end
