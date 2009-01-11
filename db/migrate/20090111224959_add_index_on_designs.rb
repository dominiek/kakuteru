class AddIndexOnDesigns < ActiveRecord::Migration
  def self.up
    add_index :designs, :stream_id
  end

  def self.down
    remove_index :designs, :stream_id
  end
end
