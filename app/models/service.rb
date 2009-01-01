class Service < ActiveRecord::Base
  belongs_to :stream
  
  TYPES            = {
    'articles'     => :article,
    'youtube'      => :video,
    'vimeo'        => :video,
    'seesmic'      => :video,
    'twitter'      => :message,
    'jaiku'        => :message,
    'plurk'        => :message,
    'identica'     => :message,
    'facebook'     => :message,
    'tumblr'       => :mixed,
    'delicious'    => :bookmark,
    'digg'         => :bookmark,
    'googlereader' => :bookmark,
    'stumbleupon'  => :bookmark,
    'hatena'       => :bookmark,
    'reddit'       => :bookmark,
    'flickr'       => :photo,
    'picasaweb'    => :photo,
    'slideshare'   => :slide,
    'wakoopa'      => :software,
    'lastfm'       => :music
  }

  
  def after_create
    fetch_profile_image! || true
  end
  
  def fetch_profile_image!
    case identifier
      when 'twitter'
        twitter = Twitter.new(profile_url.match(/twitter\.com\/([^\/]+)/)[1])
        self.update_attribute(:profile_image_url, twitter.profile_image_url)
    end
  end
  
  def actor
    return 'unknown' unless profile_url
    case identifier
      when 'youtube'
        profile_url.match(/user=([^\/]+)$/)[1]
      else
        if (m = profile_url.match(/\/([^\/]+)$/)) || (m = profile_url.match(/\/([^\/]+)\/$/))
          m[1]
        else
          profile_url
        end
    end
  end
  
  def icon_url
    "/images/services/#{identifier}.png"
  end
  
  def to_xml(options = {})
    xml = Builder::XmlMarkup.new(:indent => 2, :no_escape => true)
    xml.service(:id => id, :identifier => identifier, :name => name, :profile_url => profile_url)
  end
  
end
