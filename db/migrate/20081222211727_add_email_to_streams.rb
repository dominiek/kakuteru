class AddEmailToStreams < ActiveRecord::Migration
  def self.up
    add_column :streams, :email, :string
    Invite.find(:all, :conditions => ['used_for_stream IS NOT NULL']).each do |invite|
      stream = Stream.find_by_subdomain(invite.used_for_stream)
      next unless stream
      stream.update_attribute(:email, invite.email)
    end
  end

  def self.down
    remove_column :streams, :email
  end
end
