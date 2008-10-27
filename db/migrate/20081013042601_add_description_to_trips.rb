class AddDescriptionToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :description, :text
  end

  def self.down
    remove_column :trips, :description
  end
end
