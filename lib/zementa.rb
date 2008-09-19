
require 'net/http'
require 'rubygems'
require 'xmlsimple'

class Zementa
  
  def initialize(api_key, text)
    @api_key = api_key
    @text = text
    @gateway = 'http://api.zemanta.com/services/rest/0.0/'
    @suggest_data = nil
  end

  def tags(options = {})
    options[:confidence_cutoff] ||= 0.02
    suggest
    tags = []
    return [] unless @suggest_data['keywords']
    return [] unless @suggest_data['keywords'].first
    @suggest_data['keywords'][0]['keyword'].each { |keyword|
       next if keyword['confidence'].first.to_f <= options[:confidence_cutoff]
       tags << keyword['name'].first.downcase
    }
    tags
  end
  
  private
  
  def suggest
    return @suggest_data unless @suggest_data.nil?
    res = Net::HTTP.post_form(URI.parse(@gateway), {
                             'method' => 'zemanta.suggest',
                             'api_key'=> @api_key,
                             'text'=> @text,
                             'format' => 'xml'
    })
    @suggest_data = XmlSimple.xml_in(res.body)
  end

end