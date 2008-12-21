class StreamsController < ApplicationController
  
  def show
    if Stream::RESERVED_SUBDOMAINS.include?(@stream.subdomain)
      render(:text => 'Sorry, this is a reserved subdomain.', :layout => 'intro', :status => 403) and return false
    end
    unless @stream.is_active?
      session[:invite_code] = params[:invite_code]
      puts session[:invite_code]
      redirect_to(claim_stream_path(:invite_code => params[:invite_code])) and return
    end
    if params[:tag_name].blank?
      @posts = Post.paginate(:all, :per_page => 12, :page => params[:page], :conditions => @stream.public_posts_conditions, :order => 'published_at DESC', :include => [:service])
    else
      @posts = Post.find_tagged_with(params[:tag_name], :conditions => @stream.public_posts_conditions, :include => [:service], :limit => 12, :order => 'published_at DESC')
    end
    render(:layout => 'application')
  end
  
  def claim
    session[:invite_code] = params[:invite_code] if params[:invite_code]
    if request.post? && !@stream.is_active
      @stream.verify_invite_code!(session[:invite_code])
      if @stream.errors.blank?
        @stream.update_attributes(params[:stream])
      else
        @invalid_invite_code = true
      end
      if @stream.errors.blank?
        if @stream.authenticate(params[:stream][:new_password])
          session[:authenticated_subdomain] = @stream.subdomain
        end
        redirect_to(setup_stream_path)
      end
    end
  end
  
  def setup
    respond_to(:html, :js)
  end
  
  def delete
    if request.post?
      if @stream.authenticate(params[:password_verification])
        Post.delete_all(['stream_id = ?', @stream.id])
        #Media.delete_all(['stream_id = ?', @stream.id])
        Service.delete_all(['stream_id = ?', @stream.id])
        @stream.destroy
        redirect_to('http://kakuteru.com/')
      end
    end
  end
  
  def confirm
    if request.post?
      @stream.update_attributes(params[:stream])
    end
  end
  
  def aggregate_activity
    if request.post?
      aggregate!
    end
    respond_to(:js)
  end
  
  def aggregate_services
    respond_to(:js)
  end
  
  def status
    respond_to(:js)
  end
  
  def finalize
    @stream.update_attribute(:is_active, true)
    aggregate!(:first_time => true)
    redirect_to('/dashboard')
  end
  
  private
  
  def aggregate!(options = {})
    if @stream.aggregation_status == Stream::STATUS_READY
      @stream.update_attributes(:aggregation_status => Stream::STATUS_AGGREGATING, :aggregation_progress => 10)
      spawn do
        @stream.aggregate!(options)
      end
    end
  end
end
