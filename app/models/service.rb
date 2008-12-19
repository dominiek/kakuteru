class Service < ActiveRecord::Base
  belongs_to :stream
  
  def after_create
    if identifier == 'twitter'
      # Fetch profile_image_url
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
end
