class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :post_id
      t.string :caption
      t.string :url
      t.integer :type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
