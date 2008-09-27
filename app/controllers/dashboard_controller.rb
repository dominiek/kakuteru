class DashboardController < ApplicationController
  before_filter :require_authentication, :except => :login
  
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
  
  def logout
    session[:authenticated] = false
    redirect_to(:action => :login)
  end
  
  def toggle
    @post = Post.find(params[:id])
    @post.update_attribute(:is_deleted, !@post.is_deleted?)
    redirect_to(manage_stream_url)
  end
  
  private
  
  def login_success
    session[:authenticated] = true
    redirect_to(manage_stream_url)
  end
  
end
