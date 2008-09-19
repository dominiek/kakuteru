class PostsController < ApplicationController
  before_filter :require_authentication, :except => [:index, :show]
  
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
      @post.auto_tag! if @post.tag_list.blank?
    end
    render(:layout => 'dashboard')
  end
  
  def new
    @post = Post.new(params[:post])
    if request.post?
      @post.is_draft = true
      @post.service = Service.find_or_create_by_identifier('articles')
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
        render(:layout => 'dashboard')
      end
    end
  end
  
  def index
    @posts = @stream.posts.find(:all, :limit => 12)
    respond_to(:html, :rss, :atom)
  end
  
  def manage
    render(:layout => 'dashboard')
  end
  
end
