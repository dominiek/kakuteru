class AggregationStartedAt < ActiveRecord::Migration
  def self.up
    add_column :streams, :aggregation_started_at, :datetime, :null => true
  end

  def self.down
    remove_column :streams, :aggregation_started_at
  end
end
