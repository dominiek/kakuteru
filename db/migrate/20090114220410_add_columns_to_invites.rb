class AddColumnsToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :name, :string
    add_column :invites, :twitter_username, :string
  end

  def self.down
    remove_column :invites, :name
    remove_column :invites, :twitter_username
  end
end
