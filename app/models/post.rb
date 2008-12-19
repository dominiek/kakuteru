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
  
  def after_save
    permalink!
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
    puts "AUTO TAGGING!"
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
    self.permalink = string
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
