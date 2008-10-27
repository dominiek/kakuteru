ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  

  #map.connect '/', :controller => 'posts', :method => :index
  #map.connect '/archive', :controller => 'posts', :method => :archive
  
  map.resources :statistics
  map.resources :services
  map.resources :assets
  
=begin # Make this for subdomains
  map.with_options(:controller => 'posts') do |m|
    m.archive '/archive', :action => 'archive'
    m.manage_stream '/dashboard/stream', :action => 'manage'
    m.manage_articles '/dashboard/articles', :action => 'articles'
    m.new_post '/dashboard/articles/write', :action => 'new'
    m.edit_post 'dashboard/edit/:id', :action => 'edit'
    m.delete_post 'dashboard/delete/:id', :action => 'delete'
    
    map.connect 'dashboard/:action/:id', :controller => 'dashboard'
    
    # Support Mephisto routes, eg: http://dominiek.com/articles/2008/7/19/iphone-app-development-for-web-hackers
    m.connect '/articles/:year/:month/:day/:permalink', :action => 'show', :requirements => {:year => /\d+/, :month => /\d+/, :day => /\d+/}
    m.articles_feed '/articles.:format', :action => 'articles'
    m.stream_feed '/stream.:format'
    m.by_tag '/tag/:tag_name', :action => 'index'
    m.media '/media', :action => 'media'
    m.post '/:id', :action => 'show', :requirements => {:id => /.+/}
    m.posts '/', :action => 'index'
  end
=end
  #map.resources :posts, :collection => {:manage => :get, :archive => :get}
  
  map.intro '/', :controller => 'intro'
  map.invite '/invite', :controller => 'intro', :action => 'invite'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
