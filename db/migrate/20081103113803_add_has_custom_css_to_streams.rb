class AddHasCustomCssToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :has_custom_css, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :streams, :has_custom_css
  end
end
