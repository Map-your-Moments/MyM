class AddLatitudeColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :latitude, :decimal, :precision => 15, :scale => 10
  end
end
