
require 'ostruct'
require 'mechanize'
require 'rexml/document'
require 'date'

class Friendfeed
  
  def initialize(username)
    @username = username
  end
  
  def fetch(&block)
    agent = WWW::Mechanize.new
    page = agent.get("http://friendfeed.com/api/feed/user/#{@username}?format=xml")
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
      entry.service.identifier = xml_entry.elements['service/id'].text.to_s
      entry.service.name = xml_entry.elements['service/name'].text.to_s
      entry.service.profileUrl = xml_entry.elements['service/profileUrl'].text.to_s
      entry.service.iconUrl = xml_entry.elements['service/iconUrl'].text.to_s
      
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
      yield(entry)
    end
  end
  
  def profile
    profile = {}
    agent = WWW::Mechanize.new
    page = agent.get("http://friendfeed.com/api/user/#{@username}/profile?format=xml")
    xml = REXML::Document.new(page.body)
    profile[:name] = xml.elements['user/name'].text
    profile[:services] = []
    xml.get_elements('user/service').each do |xml_entry|
      service = OpenStruct.new
      service.identifier = xml_entry.elements['id'].text.to_s
      service.name = xml_entry.elements['name'].text.to_s
      service.profileUrl = xml_entry.elements['profileUrl'].text.to_s
      service.iconUrl = xml_entry.elements['iconUrl'].text.to_s
      profile[:services] << service
    end
    return profile
  end
end