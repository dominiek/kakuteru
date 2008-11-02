class AddFriendfeedUsernameToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :friendfeed_username, :string
  end

  def self.down
    remove_column :streams, :friendfeed_username
  end
end
