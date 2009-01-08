
require 'hpricot'
require 'parsedate'

module Fragmentors

  class HTML
    
    include PermanentFragments

    def initialize(html)
      @html = html
      @doc = Hpricot(@html)
    end
  
    ##
    # Return the relevant perma-topical content + dynamic-topical content
    def text
      
    end
  
  end

end
