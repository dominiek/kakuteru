class AddIdentifierToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :identifier, :string
  end

  def self.down
    remove_column :trips, :identifier
  end
end
