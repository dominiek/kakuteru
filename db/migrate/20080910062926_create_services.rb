class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.integer :stream_id
      t.string :name
      t.string :identifier
      t.string :profile_url
      t.string :icon_url
      t.boolean :is_enabled, :default => true, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
