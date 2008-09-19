
require 'uri'

class Link < ActiveRecord::Base
  belongs_to :post
  
  def domain
    self.class.domain_for_url(url)
  end
  
  def self.domain_for_url(url)
    uri = URI.parse(url)
    uri.host
  end
end
