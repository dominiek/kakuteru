class DashboardController < ApplicationController
  before_filter :require_authentication, :except => [:login, :forgot_password, :reset_password]
  before_filter :settings_notice, :only => [:index, :content, :services, :integration, :domain, :account]
  
  def index
    if @stream.blog_url.blank?
      @stream.update_attribute(:blog_url, "http://#{request.host_with_port}/")
    end
    if request.post?
      @stream.update_attributes(params[:stream])
    end
  end
  
  def login
    if request.post? && !params[:password].blank?
      if @stream.password
        if @stream.authenticate(params[:password])
          login_success
        end
      else
        # First time
        @stream.update_attribute(:password, params[:password])
        login_success
      end
    end  
  end
  
  def forgot_password
    if request.post?
      if @stream.forgot_password!(params[:email])
        @notice = "An e-mail has been sent to #{@stream.email}"
      end
    end
  end
  
  def reset_password
    if request.post?
      if @stream.reset_password!(params)
        login_success
      end
    end
  end
  
  def logout
    session[:authenticated_subdomain] = false
    redirect_to(:action => :login)
  end
  
  def toggle
    @post = Post.find(params[:id])
    @post.update_attribute(:is_deleted, !@post.is_deleted?)
    redirect_to(manage_stream_url)
  end
  
  def services
    if request.post?
      @stream.services.each do |service|
        service_key = "service_#{service.identifier}"
        if params[service_key] && params[service_key]['is_enabled']
          service.update_attribute(:is_enabled, :true)
        else
          service.update_attribute(:is_enabled, :false)
        end
      end
    end
  end
  
  def content
    @stream.update_attributes(params[:stream]) if request.post?
  end
  
  def integration
    @stream.update_attributes(params[:stream]) if request.post?
  end
  
  def domain
    @stream.update_attributes(params[:stream]) if request.post?
  end
  
  def account
    @stream.update_attributes(params[:stream]) if request.post?
  end
  
  private
  
  def login_success
    session[:authenticated_subdomain] = @stream.subdomain
    redirect_to(manage_stream_url)
  end
  
  def settings_notice
    if request.post?
      @notice = 'Settings saved'
    end
  end
  
end
