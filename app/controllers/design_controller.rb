class DesignController < ApplicationController
  before_filter :require_authentication
  layout 'dashboard'
  
  def index
    if request.post?
      @stream.update_attributes(params[:stream])
      @notice = 'CSS updated'
    end
    if request.delete?
      @stream.clear_custom_css!
      @notice = 'CSS restored'
    end
  end
end
