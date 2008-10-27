class AddFooterToStream < ActiveRecord::Migration
  def self.up
    add_column :streams, :footer, :text
  end

  def self.down
    remove_column :streams, :footer
  end
end
