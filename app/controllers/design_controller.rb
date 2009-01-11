class DesignController < ApplicationController
  before_filter :require_authentication
  layout 'dashboard'
  
  def index
    if request.post? && params[:stream]
      @stream.update_attributes(params[:stream])
      @notice = 'CSS updated'
    end
    if request.delete?
      @stream.clear_custom_css!
      @notice = 'CSS restored'
    end
    
    @design = @stream.design || Design.new(params[:design])
    if request.post? && params[:design]
      @stream.design ||= Design.new
      @stream.save
      @stream.design.update_attributes(params[:design])
    end
  end
end
