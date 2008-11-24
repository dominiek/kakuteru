require 'md5'

class Invite < ActiveRecord::Base
  
  def self.generate_codes!(options = {})
    Invite.find(:all, :conditions => ['code IS NULL AND is_used = 0']).each do |invite|
      invite.update_attribute(:code, MD5.hexdigest(invite.email))
    end
  end
  
end
