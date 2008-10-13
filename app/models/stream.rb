class Stream < ActiveRecord::Base
  has_many :posts, :conditions => 'is_deleted IS FALSE', :order => 'published_at DESC'
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
    :include => [:medias],
    :conditions => "is_deleted IS FALSE AND medias.id IS NOT NULL", 
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
  
  def authenticate(password)
    if self.password == password
      true
    else
      self.errors.add(:password, 'Invalid password mate!')
      false
    end
  end
  
  def self.current
    self.find_or_create_by_id(1)
  end
end
