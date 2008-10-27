class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :post_id
      t.string :path
      t.string :file_type
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
