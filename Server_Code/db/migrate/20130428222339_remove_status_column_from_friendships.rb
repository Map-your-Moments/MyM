class RemoveStatusColumnFromFriendships < ActiveRecord::Migration
  def up
    remove_column :friendships, :status
  end

  def down
    add_column :friendships, :status, :string
  end
end
