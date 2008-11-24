
require 'digest/sha2'

class Stream < ActiveRecord::Base
  has_many :posts, 
    :conditions => 'is_deleted IS FALSE', 
    :order => 'published_at DESC'
  has_many :public_posts,
    :include => [:service],
    :conditions => 'is_deleted IS FALSE AND services.is_enabled = true',
    :order => 'published_at DESC',
    :class_name => 'Post'
  has_many :articles, 
    :include => [:service],
    :conditions => "is_deleted IS FALSE AND is_draft IS FALSE AND services.identifier = 'articles'", 
    :order => 'published_at DESC', 
    :class_name => 'Post'
  has_many :drafts, 
    :include => [:service],
    :conditions => "is_deleted IS FALSE AND is_draft IS TRUE  AND services.identifier = 'articles'", 
    :order => 'posts.created_at DESC', 
    :class_name => 'Post'
  has_many :media_posts,
    :include => [:medias, :service],
    :conditions => ["is_deleted IS FALSE AND medias.id IS NOT NULL AND services.is_enabled = 1 AND services.identifier IN (?)", Media::SUPPORTED_SERVICES], 
    :order => 'posts.published_at DESC', 
    :class_name => 'Post',
    :limit => 4
  has_many :services do
    def public(options = {})
      find(:all, options.merge(:conditions => "is_enabled IS TRUE AND identifier != 'blog'"))
    end
  end
  has_many :upcoming_trips,
    :conditions => "travel_starts_at > NOW()",
    :class_name => 'Trip',
    :limit => 8
  attr_accessor :new_password, 
                :new_password_repeat
                
  STATUS_READY = 0
  STATUS_AGGREGATING = 1
  RESERVED_SUBDOMAINS = ['blog', 'admin', 'kakuteru', 'status', 'developer', 'api', 'wiki', 'help', 'dominiek', 'zemanta', 'friendfeed', 'iknow', 'reccoon']
  
  include Statistics
  
  def verify_invite_code!(code)
    puts code
    invite = Invite.find(:first, :conditions => ['is_used = 0 AND code = ?', code])
    if invite.blank?
      self.errors.add(:password, 'Invalid invite code mate!')
      return false
    end
    invite.update_attribute(:used_for_stream, subdomain)
    true
  end
  
  def authenticate(password)
    if self.password == Digest::SHA512.hexdigest(password)
      true
    else
      self.errors.add(:password, 'Invalid password mate!')
      false
    end
  end
  
  def before_save
    if self.new_password
      if self.new_password.blank?
        self.errors.add(:password, "Please choose a magic word.")
      end
      if self.new_password != self.new_password_repeat
        self.errors.add(:password, "Woops, passwords didn't match!")
      else
        self.password = Digest::SHA512.hexdigest(self.new_password)
      end
    end
  end
  
  def self.aggregate!
    time = Time.now
    streams = Stream.find(:all, :conditions => ["friendfeed_username IS NOT NULL AND is_active = 1"]) 
    logger.info("Updating #{streams.size} streams")
    streams.each do |stream|
      begin
        stream.aggregate!
      rescue => e
        logger.error(e)
      end
    end
    logger.info("Stream.aggregate! took #{(Time.now - time).to_i} seconds")
  end
  
  def aggregate_services!(options = {})
    profile = Friendfeed.new(self.friendfeed_username).profile
    if !self.author
      self.update_attribute(:author, profile[:name])
    end
    profile[:services].each do |ff_service|
      find_or_create_service(ff_service)
    end
  end
  
  def aggregate!(options = {})
    update_attribute(:aggregation_started_at, Time.now)
    entries = Friendfeed.new(self.friendfeed_username).activity
    update_attribute(:aggregation_progress, 50)
    entries_count = entries.size
    entries.each_with_index do |entry,i|
      service = find_or_create_service(entry.service)
                              
      post = Post.find_by_identifier_and_stream_id(entry.identifier, self.id)
      next if post
      post = Post.create(:identifier => entry.identifier, :stream_id => self.id)
      post.update_attributes(:caption => entry.title,
                             :published_at => entry.published,
                             :service => service)
      post.auto_tag!
      post.permalink!

      if entry.link
        post.links.find_or_create_by_url(entry.link)
      end
      
      unless entry.medias.blank?
        entry.medias.each do |media_entry|
          media = post.medias.find_or_create_by_url(media_entry.link)
          embed_url = media_entry.content.blank? ? media_entry.enclosure : media_entry.content
          media.update_attributes(:caption => media_entry.title,
                                  :thumbnail_url => media_entry.thumbnail,
                                  :embed_url => embed_url)
        end
      end
      update_attribute(:aggregation_progress, 50+((50/entries_count)*(i+1)))
    end
    
    update_attributes(:aggregation_progress => 100, 
                      :aggregation_status => Stream::STATUS_READY,
                      :aggregation_started_at => nil)
  rescue => e
    puts e.backtrace.join("\n")
  end
  
  def aggregate_from_gnip
    require 'rubygems'
    require 'gnip'

    gnip = Gnip::Connection.new(Gnip::Config.new(GNIP_EMAIL, GNIP_PASSWORD))
    twitter = Gnip::Publisher.new('twitter')
    twitter_filter = Gnip::Filter.new('kakuteru-twitter')
    twitter_filter.add_rule('actor', self.services.find_by_identifier('twitter').actor)
    gnip.create_filter(twitter, twitter_filter)

    activities = gnip.filter_notifications_stream(twitter, twitter_filter)
    puts activities.inspect
  end
  
  def css
    if File.exists?(css_file_path)
      fp = File.open(css_file_path, 'r')
      css_data = fp.read
      fp.close
      css_data
    else
      self.class.default_css
    end
  end
  
  def css=(data)
    fp = File.open(css_file_path, 'w')
    fp.write(data)
    fp.close
    self.has_custom_css = true
  end
  
  def self.default_css
    default_css_file_path = File.join(RAILS_ROOT, 'public/stylesheets', 'default') + '.css'
    fp = File.open(default_css_file_path, 'r')
    css_data = fp.read
    fp.close
    css_data
  end
  
  def to_s
    unless self.title.blank?
      return self.title
    end
    unless self.author.blank?
      return self.author
    end
    return self.subdomain
  end
  
  def friendly_url
    self.blog_url.to_s.gsub(/^http:\/\//, '').gsub(/\//, '')
  end
  
  def busy?
    if self.aggregation_started_at && self.aggregation_started_at < 4.minutes.ago
      update_attributes(:aggregation_progress => 100, 
                        :aggregation_status => Stream::STATUS_READY,
                        :aggregation_started_at => nil)
    end
    self.aggregation_status != STATUS_READY
  end
  
  def tag_counts(options = {})
    @tag_counts ||= Tag.counts(
      :limit => 40, 
      :order => 'count DESC',
      :joins => " JOIN posts ON taggable_type = 'Post' AND taggable_id = posts.id ",
      :conditions => ["posts.stream_id = #{self.to_param}"]
    )
  end
  
  protected
  
  def graph_colors
    ['173F1D', '3B9F49', '53DF66', 'A4EFAE', '6FDFD2', '2BAFA0', '0D6F64']
  end
  
  def find_or_create_service(ff_service)
    return if ff_service.identifier == 'blog'
    service = Service.find_or_create_by_identifier_and_stream_id_and_profile_url(ff_service.identifier, self.id, ff_service.profileUrl)
    service.update_attributes(:name => ff_service.name,
                              :profile_url => ff_service.profileUrl,
                              :icon_url => ff_service.iconUrl)
    service
  end
  
  def css_file_path
    File.join(RAILS_ROOT, 'public/stylesheets', self.subdomain) + '.css'
  end
  
end
