class GnipController < ApplicationController
  
  def index
    render(:text => 'hello')
    puts params.inspect
  end
  
  def create
    puts params.inspect
  end
  
end
