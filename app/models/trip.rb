class Trip < ActiveRecord::Base
  
  def self.fetch_from_dopplr
    require 'mechanize'
    require 'icalendar'
    agent = WWW::Mechanize.new
    page = agent.get(Stream.current.dopplr_ical_url.gsub(/^webcal:\/\//, 'http://'))
    calendars = Icalendar.parse(page.body)
    events = calendars.first.events
    sampled_dopplr_url = nil
    events.each do |event|
      trip = Trip.find_or_create_by_identifier_and_stream_id(event.uid, Stream.current.id)
      trip.update_attributes(:travel_starts_at => event.dtstart,
                             :travel_ends_at => event.dtend,
                             :destination => event.location,
                             :url => event.url.to_s,
                             :description => event.description)
      sampled_dopplr_url ||= event.url
    end
    
    if sampled_dopplr_url
      dopplr_username = sampled_dopplr_url.to_s.match(/\/trip\/([\w]+)\//)[1]
      dopplr_service = Service.find_or_create_by_identifier_and_stream_id('dopplr', Stream.current.id)
      dopplr_service.update_attributes(:icon_url => '/images/services/dopplr.png',
                                       :name => 'Dopplr',
                                       :profile_url => "http://www.dopplr.com/traveller/#{dopplr_username}")
    end
  end
end
