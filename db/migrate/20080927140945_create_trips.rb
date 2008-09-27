class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.string :destination
      t.datetime :travel_starts_at
      t.datetime :travel_ends_at
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
