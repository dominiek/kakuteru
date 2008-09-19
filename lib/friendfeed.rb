
require 'ostruct'
require 'mechanize'
require 'rexml/document'
require 'date'

class Friendfeed
  
  def initialize(url)
    @url = url
  end
  
  def fetch(&block)
    agent = WWW::Mechanize.new
    page = agent.get(@url)
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
end