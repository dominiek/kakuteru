class PostsController < ApplicationController
  before_filter :require_authentication, :except => [:index, :show, :archive, :articles, :media]
  
  def show
    if params[:permalink]
      @post = Post.find_by_permalink(params[:permalink])
    else
      @post = Post.find(params[:id])
    end
  end
  
  def edit
    @post = Post.find(params[:id])
    if request.post?
      @post.update_attributes(params[:post])
      if !@post.is_draft?
        @post.update_attribute(:published_at, Time.now) unless @post.published_at
      end
      @post.auto_tag! if @post.tag_list.blank?
    end
    render(:layout => 'dashboard')
  end
  
  def delete
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to(manage_articles_url)
  end
  
  def archive
    @posts = @stream.posts.find(:all, :include => [:service], :conditions => ["services.identifier = 'articles'"])
  end
  
  def new
    @post = Post.new(params[:post])
    if request.post?
      @post.is_draft = true
      @post.service = Service.find_or_create_by_stream_id_and_identifier(@stream.id, 'articles')
      @post.stream = @stream
      @post.save
      @post.auto_tag! if @post.tag_list.blank?
      redirect_to(edit_post_url(:id => @post.id)) and return
    end
    render(:layout => 'dashboard')
  end
  
  def articles
    @articles = @stream.articles.find(:all, :limit => 10)
    respond_to do |format|
      format.rss
      format.atom
      format.html do
        require_authentication
        render(:layout => 'dashboard')
      end
    end
  end
  
  def index
    if params[:tag_name].blank?
      #
      @posts = Post.paginate(:all, :per_page => 12, :page => params[:page], :conditions => @stream.public_posts_conditions, :order => 'published_at DESC', :include => [:service])
      #@posts = @stream.posts.paginate(:all, :limit => 12)
    else
      @posts = Post.find_tagged_with(params[:tag_name], :conditions => @stream.public_posts_conditions, :limit => 12, :include => [:service])
    end
    respond_to(:html, :rss, :atom)
  end
  
  def manage
    @posts = Post.find(:all, :include => [:service], :conditions => ["services.identifier != 'articles' AND posts.stream_id = ?", @stream.id], :order => 'posts.published_at DESC')
    render(:layout => 'dashboard')
  end
  
  def media
    @media_posts = Post.paginate(:all, 
                                 :per_page => 12, 
                                 :page => params[:page], 
                                 :include => [:medias, :service],
                                 :conditions => ["is_deleted IS FALSE AND medias.id IS NOT NULL AND services.is_enabled = 1 AND services.identifier IN (?) AND posts.stream_id = ?", Media::SUPPORTED_SERVICES, @stream.id], 
                                 :order => 'posts.created_at DESC')
                                 
  end
  
end
