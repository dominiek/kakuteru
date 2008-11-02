class AddSubdomainToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :subdomain, :string
  end

  def self.down
    remove_column :streams, :subdomain
  end
end
