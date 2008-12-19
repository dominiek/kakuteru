class AddMailSentToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :mail_sent, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :invites, :mail_sent
  end
end
