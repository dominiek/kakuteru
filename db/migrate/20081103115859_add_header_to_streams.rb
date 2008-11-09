class AddHeaderToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :header, :text
  end

  def self.down
    remove_column :streams, :header
  end
end
