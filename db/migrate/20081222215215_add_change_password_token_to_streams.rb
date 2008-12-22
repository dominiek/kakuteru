class AddChangePasswordTokenToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :change_password_token, :string
  end

  def self.down
    remove_column :streams, :change_password_token
  end
end
