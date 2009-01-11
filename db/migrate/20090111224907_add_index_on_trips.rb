class AddIndexOnTrips < ActiveRecord::Migration
  def self.up
    add_index :trips, :stream_id
  end

  def self.down
    remove_index :trips, :stream_id
  end
end
