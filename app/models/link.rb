
require 'uri'

class Link < ActiveRecord::Base
  belongs_to :post
  
  def domain
    self.class.domain_for_url(url)
  end
  
  def self.domain_for_url(url)
    uri = URI.parse(url)
    uri.host
  rescue => e
    m = url.match(/http:\/\/([^\/]+)/)
    m ? m[1] : nil
  end
  
  def to_xml(options = {})
    xml = Builder::XmlMarkup.new(:indent => 2, :no_escape => true)
    xml.link(:id => id, :domain => domain, :url => url)
  end
  
end
