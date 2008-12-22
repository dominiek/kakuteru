# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :load_stream

  class KakuteruError < StandardError; end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8894fc42900d096ee1572f6ee1bb3420'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  protected
  
  def require_authentication
    if session[:authenticated_subdomain] == request.subdomains.first
      @authenticated = true
    else
      redirect_to("http://#{@stream.subdomain}.#{KAKUTERU_DOMAIN}/dashboard/login")
    end
  end
  
  def load_stream
    @subdomain = request.subdomains.first
    @domain = request.domain
    if @subdomain && @subdomain != 'kakuteru' && @domain =~ /kakuteru|localhost|test\.host/
      @stream = Stream.find_or_create_by_subdomain(@subdomain)
    else
      @stream = Stream.find_by_domain(@domain)
      @using_custom_domain = true
    end
  end
  
end
