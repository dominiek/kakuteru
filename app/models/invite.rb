require 'md5'
require 'twitter'

class Invite < ActiveRecord::Base
  
  def self.generate_codes!(options = {})
    Invite.find(:all, :conditions => ['code IS NULL AND is_used = 0']).each do |invite|
      invite.update_attribute(:code, MD5.hexdigest(invite.email || invite.twitter_username))
    end
  end
  
  def self.email_all!
    Invite.find(:all, :conditions => ['email IS NOT NULL AND code IS NOT NULL AND is_used = 0 AND mail_sent = 0']).each do |invite|
      begin
        Inviter.deliver_invite(invite)
      rescue => e
        logger.error("error sending invite to #{invite.email}: #{e.to_s}")
        logger.error(e)
      end
      invite.update_attribute(:mail_sent, true)
      sleep(9)
    end
  end
  
  def self.tweet_all!(username, password)
    twitter = Twitter::Base.new(username, password)
    Invite.find(:all, :conditions => ['twitter_username IS NOT NULL AND code IS NOT NULL AND is_used = 0 AND mail_sent = 0']).each do |invite|
      begin
        Invite.tweet!(twitter, invite)
      rescue => e
        logger.error("error sending invite to #{invite.twitter_username}: #{e.to_s}")
        logger.error(e)
      end
      invite.update_attribute(:mail_sent, true)
      sleep(9)
    end
  end
  
  def self.tweet!(twitter, invite)
    if invite.twitter_username.blank?
      raise StandardError.new("Could not send invite to: #{invite.inspect} - invite.twitter_username is blank!")
    end
    if invite.code.blank?
      raise StandardError.new("Could not send invite to: #{twitter_username} - invite.code is blank!")
    end
    twitter.d(invite.twitter_username, "Hey, thanks for the support! Your invite: http://kakuteru.com?invite_code=#{invite.code}")
    invite.update_attribute(:mail_sent, true)
  end
  
  def self.create_invites_from_followers(username, password)
    twitter = Twitter::Base.new(username, password)
    followers = get_all_followers(twitter)
    followers.each do |twitter_username|
      invite = Invite.find_or_create_by_twitter_username(twitter_username)
    end
  end
  
  def self.follow_all_followers(username, password)
    twitter = Twitter::Base.new(username, password)
    friends = []
    0.upto(5) do |page|
      friends_on_page = twitter.friends(:page => page)
      break if friends_on_page.blank?
      friends << friends_on_page
    end
    friends.flatten!
    friends = friends.collect(&:screen_name)
    
    followers = get_all_followers(twitter)
    
    followers.each do |screen_name|
      if !friends.include?(screen_name)
        puts "Following: #{screen_name}"
        begin
          twitter.create_friendship(screen_name)
        rescue => e
          puts "FAIL (create_friendship)"
        end
        begin
          twitter.follow(screen_name)
        rescue => e
          puts "FAIL (follow)"
        end
      end
    end
  end
  
  private
  
  def self.get_all_followers(twitter)
    followers = []
    0.upto(5) do |page|
      followers_on_page = twitter.followers(:page => page)
      break if followers_on_page.blank?
      followers << followers_on_page
    end
    followers.flatten!
    followers.collect(&:screen_name)
  end
  
end
