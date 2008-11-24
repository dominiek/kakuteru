class AddInviteCodeToStreams < ActiveRecord::Migration
  def self.up
    add_column :invites, :code, :string, :null => true, :limit => 512
    add_column :invites, :used_for_stream, :string, :null => true
  end

  def self.down
    remove_column :invites, :code
    remove_column :invites, :used_for_stream
  end
end
