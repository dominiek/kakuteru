class AddIsUsedToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :is_used, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :invites, :is_used
  end
end
