class AddActiveToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :is_active, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :streams, :is_active
  end
end
