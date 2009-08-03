
require 'ostruct'
require 'mechanize'
require 'rexml/document'
require 'date'

class Friendfeed
  class UnknownProfileError < StandardError; end
  
  def initialize(username)
    @username = username
  end
  
  def activity(options = {})
    entries = []
    agent = WWW::Mechanize.new
    additional_parameters = ""
    unless options[:limit].blank?
      additional_parameters = "&num=#{options[:limit]}"
    end
    page = agent.get("http://friendfeed.com/api/feed/user/#{@username}?format=xml" + additional_parameters)
    xml = REXML::Document.new(page.body)
    xml.elements['/feed'].each do |xml_entry|
      next unless xml_entry.name == 'entry'
      entry = OpenStruct.new
      entry.identifier = xml_entry.get_text('id').to_s
      entry.title = xml_entry.get_text('title').to_s
      entry.link = xml_entry.get_text('link').to_s
      if xml_entry.elements['published']
        entry.published = DateTime.parse(xml_entry.elements['published'].text).to_time
        entry.updated = DateTime.parse(xml_entry.elements['updated'].text).to_time
      end
      entry.service = OpenStruct.new
      entry.service.identifier = text_or_nil(xml_entry.elements['service/id'])
      entry.service.name = text_or_nil(xml_entry.elements['service/name'])
      entry.service.profileUrl = text_or_nil(xml_entry.elements['service/profileUrl'])
      # Hack for weird bug
      entry.service.profileUrl = entry.service.profileUrl.gsub(/\/statuses.*/, '')
      entry.service.iconUrl = text_or_nil(xml_entry.elements['service/iconUrl'])
      
      entry.medias = []
      xml_entry.get_elements('media').each do |xml_media|
        media = OpenStruct.new
        media.title = xml_media.get_text('title').to_s
        media.link = xml_media.get_text('link').to_s
        media.thumbnail = xml_media.get_text('thumbnail/url').to_s
        media.enclosure = xml_media.get_text('enclosure/url').to_s
        media.content = xml_media.get_text('content/url').to_s
        entry.medias << media
      end
      entries << entry
    end
    entries
  end
  
  def profile
    profile = {}
    agent = WWW::Mechanize.new
    begin
      page = agent.get("http://friendfeed.com/api/user/#{@username}/profile?format=xml")
    rescue WWW::Mechanize::ResponseCodeError => e
      raise UnknownProfileError.new
    end
    xml = REXML::Document.new(page.body)
    profile[:name] = xml.elements['user/name'].text
    profile[:services] = []
    xml.get_elements('user/service').each do |xml_entry|
      service = OpenStruct.new
      service.identifier = text_or_nil(xml_entry.elements['id'])
      service.name = text_or_nil(xml_entry.elements['name'])
      service.profileUrl = text_or_nil(xml_entry.elements['profileUrl'])
      service.iconUrl = text_or_nil(xml_entry.elements['iconUrl'])
      profile[:services] << service
    end
    return profile
  end
  
  private
  
  def text_or_nil(element)
    element.blank? ? nil : element.text.to_s
  end
end