class RemoveOauthTables < ActiveRecord::Migration
  def up
    drop_table :oauth_nonces
    drop_table :oauth_tokens
  end

  def down
  end
end
