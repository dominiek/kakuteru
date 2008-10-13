class AddUrlToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :url, :string
  end

  def self.down
    remove_column :trips, :url
  end
end
