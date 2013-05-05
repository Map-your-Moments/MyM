class AddTypeColumnToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :type, :string, :default => 'PendingFriendship'
  end
end
