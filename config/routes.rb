
#IS_GLOBAL_CONDITION = {:subdomain => /^$/,  :domain => /kakuteru\.[a-z]+/}
#IS_STREAM_CONDITION = {:subdomain => /^.+$/}

IS_GLOBAL_CONDITION = {:host => /^kakuteru\.[a-z]+$/}
IS_STREAM_CONDITION = {:host => /^.+$/}

ActionController::Routing::Routes.draw do |map|
  
  map.resources :statistics
  map.resources :assets
  #map.resources :gnip
  
  map.intro '/', :controller => 'intro', :conditions => IS_GLOBAL_CONDITION
  map.invite '/invite', :controller => 'intro', :action => 'invite', :conditions => IS_GLOBAL_CONDITION
  
  map.with_options(:controller => 'streams', :conditions => IS_STREAM_CONDITION) do |m|
    m.stream '/', :action => 'show'
    m.by_tag '/tag/:tag_name', :action => 'show'
    m.claim_stream '/claim', :action => 'claim'
    m.setup_stream '/setup', :action => 'setup'
    m.delete_stream '/delete', :action => 'delete'
    m.setup_confirm '/setup/confirm', :action => 'confirm'
    m.setup_aggregate_services '/aggregate/services', :action => 'aggregate_services'
    m.aggregate_activity '/aggregate/activity', :action => 'aggregate_activity'
    m.aggregation_status '/aggregate/status', :action => 'status'
    m.finalize_setup '/setup/finalize', :action => 'finalize'
  end
  
  map.with_options(:controller => 'posts', :conditions => IS_STREAM_CONDITION) do |m|
    m.archive '/archive', :action => 'archive'
    m.manage_stream '/dashboard/stream', :action => 'manage'
    m.post_caption '/dashboard/stream/caption/:id', :action => 'caption'
    m.manage_articles '/dashboard/articles', :action => 'articles'
    m.new_post '/dashboard/articles/write', :action => 'new'
    m.edit_post 'dashboard/edit/:id', :action => 'edit'
    m.delete_post 'dashboard/delete/:id', :action => 'delete'
    
    map.dashboard 'dashboard', :controller => 'dashboard', :conditions => IS_STREAM_CONDITION
    map.design 'dashboard/design', :controller => 'design', :conditions => IS_STREAM_CONDITION
    map.connect 'dashboard/:action/:id', :controller => 'dashboard', :conditions => IS_STREAM_CONDITION
    
    # Support Mephisto routes, eg: http://dominiek.com/articles/2008/7/19/iphone-app-development-for-web-hackers
    m.connect '/articles/:year/:month/:day/:permalink', :action => 'show', :requirements => {:year => /\d+/, :month => /\d+/, :day => /\d+/}
    m.articles_feed '/articles.:format', :action => 'articles'
    m.stream_feed '/stream.:format'
    m.media '/media', :action => 'media'
    m.post '/:id', :action => 'show', :requirements => {:id => /.+/}
  end
  #map.resources :posts, :collection => {:manage => :get, :archive => :get}

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
