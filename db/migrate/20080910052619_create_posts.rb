class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :stream_id
      t.integer :service_id
      t.string :identifier
      t.string :caption
      t.string :permalink
      t.string :markup
      t.text :body
      t.text :summary
      t.datetime :published_at
      t.boolean :is_deleted, :default => false, :null => false
      t.boolean :is_draft, :default => false, :null => false
      t.boolean :is_votable, :default => false, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
