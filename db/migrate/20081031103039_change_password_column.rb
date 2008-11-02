class ChangePasswordColumn < ActiveRecord::Migration
  def self.up
    #remove_column :streams, :password
    add_column :streams, :password, :string, :limit => 128
  end

  def self.down
  end
end
