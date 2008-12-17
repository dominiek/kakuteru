class AddDomainToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :domain, :string
  end

  def self.down
    remove_column :streams, :domain
  end
end
