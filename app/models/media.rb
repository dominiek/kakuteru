class Media < ActiveRecord::Base
  belongs_to :post
  
  SUPPORTED_SERVICES = ['flickr', 'vimeo', 'youtube', 'seesmic', 'picasaweb', 'brightkite']
  
  def big_thumbnail_url
    if self.thumbnail_url =~ /flickr\.com/
      self.thumbnail_url.gsub(/_s\.jpg/, '.jpg')
    else
      self.embed_url
    end
  end
  
  def to_xml(options = {})
    xml = Builder::XmlMarkup.new(:indent => 2, :no_escape => true)
    xml.media(:id => id) do
      xml.caption { xml.cdata!(caption) }
      xml.url(url)
      xml.embed_url(embed_url)
      xml.thumbnail_url(thumbnail_url)
    end
  end
end