class DesignController < ApplicationController
  before_filter :require_authentication
  layout 'dashboard'
  
  def index
    if request.post?
      @stream.update_attributes(params[:stream])
    end
  end
end
