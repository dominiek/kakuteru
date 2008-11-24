class Media < ActiveRecord::Base
  belongs_to :post
  
  SUPPORTED_SERVICES = ['flickr', 'vimeo', 'youtube', 'picasaweb']
  
  def big_thumbnail_url
    if self.thumbnail_url =~ /flickr\.com/
      self.thumbnail_url.gsub(/_s\.jpg/, '.jpg')
    else
      self.embed_url
    end
  end
end