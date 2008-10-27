class ServicesController < ApplicationController
  before_filter :require_authentication
  layout 'dashboard'
  
  def create
    @stream.services.each do |service|
      service_key = "service_#{service.identifier}"
      if params[service_key] && params[service_key]['is_enabled']
        service.update_attribute(:is_enabled, :true)
      else
        service.update_attribute(:is_enabled, :false)
      end
    end
    redirect_to(services_url)
  end
end
