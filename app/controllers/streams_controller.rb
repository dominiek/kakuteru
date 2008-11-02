class StreamsController < ApplicationController
  
  def show
    unless @stream.is_active?
      redirect_to(claim_stream_path) and return
    end
    if params[:tag_name].blank?
      @posts = Post.paginate(:all, :per_page => 12, :page => params[:page], :conditions => ["is_deleted IS false"], :order => 'published_at DESC')
    else
      @posts = Post.find_tagged_with(params[:tag_name], :conditions => 'is_draft IS FALSE AND is_deleted IS FALSE', :limit => 12)
    end
    render(:layout => 'application')
  end
  
  def claim
    if request.post?
      @stream.update_attributes(params[:stream])
      if @stream.errors.blank?
        puts @stream.reload.password
        if @stream.authenticate(params[:stream][:new_password])
          session[:authenticated_subdomain] = @stream.subdomain
        end
        redirect_to(setup_stream_path)
      end
    end
  end
  
  def setup
    if request.post?
      @stream.update_attributes(params[:stream])
    end
    respond_to(:html, :js)
  end
  
  def aggregate_activity
    #@stream.aggregate!
    respond_to(:js)
  end
  
  def aggregate_services
    #@stream.aggregate_services!
    respond_to(:js)
  end
  
  def finalize
    @stream.update_attribute(:is_active, true)
    redirect_to('/dashboard')
  end
end
