class CreateDesigns < ActiveRecord::Migration
  def self.up
    create_table :designs do |t|
      t.integer :stream_id
      t.text :layout
      t.integer :number_of_updates
      t.boolean :has_custom_css
      t.timestamps
    end
  end

  def self.down
    drop_table :designs
  end
end
