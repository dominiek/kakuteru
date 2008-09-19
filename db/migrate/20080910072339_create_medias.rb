class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.integer :post_id
      t.string :caption
      t.string :url
      t.string :thumbnail_url
      t.string :embed_url
      t.timestamps
    end
  end

  def self.down
    drop_table :medias
  end
end
