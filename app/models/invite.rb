require 'md5'

class Invite < ActiveRecord::Base
  
  def self.generate_codes!(options = {})
    Invite.find(:all, :conditions => ['code IS NULL AND is_used = 0']).each do |invite|
      invite.update_attribute(:code, MD5.hexdigest(invite.email))
    end
  end
  
  def self.all!
    Invite.find(:all, :conditions => ['code IS NOT NULL AND is_used = 0 AND mail_sent = 0']).each do |invite|
      begin
        Inviter.deliver_invite(invite)
      rescue => e
        logger.error("error sending invite to #{invite.email}: #{e.to_s}")
        logger.error(e)
      end
      invite.update_attribute(:mail_sent, true)
    end
  end
  
end
