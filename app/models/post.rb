class Post < ActiveRecord::Base
  belongs_to :stream
  has_many :links
  has_many :medias
  belongs_to :service
  
  acts_as_taggable
  
  include Ping
  
  SUPPORTED_MARKUP_FORMATS = [
    ['textile', 'textile'],
    ['markdown', 'markdown'],
    ['html', '']
  ]
  
  def after_save
    if self.type == 'article' && self.is_draft == false && !self.published_at
      self.update_attribute(:published_at, Time.now)
      #send_aggregation_pings
    end
  end
  
  def after_create
    permalink!
  end
  
  def self.fetch_from_friendfeed
    friendfeed = Friendfeed.new(Stream.current.friendfeed_url)
    friendfeed.fetch do |entry|
      service = Service.find_or_create_by_identifier_and_stream_id_and_profile_url(entry.service.identifier, Stream.current.id, entry.service.profileUrl)
      service.update_attributes(:name => entry.service.name,
                                :profile_url => entry.service.profileUrl,
                                :icon_url => entry.service.iconUrl)
                                
                                
      post = Post.find_or_create_by_identifier_and_stream_id(entry.identifier, Stream.current.id)
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
    end
  end
  
  def url
    links.blank? ? '#' : links.first.url
  end
  
  def related
    return [] if tag_list.blank?
    Post.find(:all,
              :select => 'posts.*, COUNT(taggings.id) AS num_tag_matches',
              :joins => " INNER JOIN taggings ON posts.id = taggings.taggable_id AND taggings.taggable_type = 'Post' AND taggings.tag_id IN (#{tags.collect(&:id).join(',')}) ",
              :group => 'posts.id HAVING num_tag_matches > 1',
              :order => 'num_tag_matches DESC',
              :conditions => ["posts.id != ? AND stream_id = ?", id, self.stream.to_param],
              :limit => 5)
  end
  
  def type
    return unless self.service
    case self.service.identifier
      when 'youtube'
        'video'
      when 'vimeo'
        'video'
      when 'twitter'
        'message'
      when 'delicious'
        'bookmark'
      when 'articles'
        'article'
      when 'flickr'
        'photo'
      when 'slideshare'
        'slide'
      when 'wakoopa'
        'software'
      when 'lastfm'
        'music'
    end
  end
  
  def caption=(new_caption)
    if self.caption != new_caption
      add_tags_for(new_caption)
    end
    super(new_caption)
  end
  
  def auto_tag!
    case self.type
      when 'message'
        self.tag_list = self.tag_list + Zementa.new(ZEMENTA_API_KEY, self.caption).tags
      when 'article'
        self.tag_list = self.tag_list + Zementa.new(ZEMENTA_API_KEY, self.body).tags
      # Bookmarks and media need extra calls, since Friendfeed isn't providing those
    end
    save
  end
  
  def permalink!
    return unless caption
    string = caption.dup
    string.to_s
    string.strip!
    string.downcase!
    string.gsub!(/[^a-zA-Z0-9]/, '-')
    string.gsub!(/-{2,}/, '-')
    string.gsub!(/^-/, '')
    string.gsub!(/-$/, '')
    string.slice(0, 60)
    update_attribute(:permalink, string)
  end
  
  private
  
  def send_aggregation_pings
    ping("rpc.technorati.com", Stream.current.title, Stream.current.blog_url)
    ping("rpc.pingomatic.com", Stream.current.title, Stream.current.blog_url)
  end
  
  def add_tags_for(caption)
    words = caption.split(/[^a-zA-Z\-]+/).find_all { |w| w =~ /[a-z]+/ }
    extracted_tags = []
    words.each do |word|
      if word.size > 12 || word[0] == word.upcase[0]
        extracted_tags << word.downcase
      end
    end
    self.tag_list = self.tag_list + extracted_tags
  end
  
end
