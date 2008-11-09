class AddStatusFieldToStream < ActiveRecord::Migration
  def self.up
    add_column :streams, :aggregation_status, :integer, :null => false, :default => 0
    add_column :streams, :aggregation_progress, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :streams, :aggregation_status
    remove_column :streams, :aggregation_progress
  end
end
