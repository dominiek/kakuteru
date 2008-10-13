class AddDopplrIcalUrlToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :dopplr_ical_url, :string
  end

  def self.down
    remove_column :streams, :dopplr_ical_url
  end
end
