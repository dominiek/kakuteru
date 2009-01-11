class AddIndexToLinks < ActiveRecord::Migration
  def self.up
    add_index :links, :post_id
  end

  def self.down
    remove_index :links, :post_id
  end
end
