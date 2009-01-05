class AddOptimizationIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :stream_id
    add_index :posts, :service_id
    add_index :medias, :post_id
  end

  def self.down
    remove_index :medias, :post_id
    remove_index :posts, :service_id
    remove_index :posts, :stream_id
  end
end
