require RAILS_ROOT + '/test/test_helper'

class StreamsControllerTest < ActionController::TestCase

  def test_reserved_subdomains
    set_subdomain('blog')
    get(:show, {}, {})
    assert_response(:forbidden)

    set_subdomain('monkey')
    get(:show, {}, {})
    assert_redirected_to(claim_stream_url)
    
    set_subdomain('kirk')
    get(:show, {}, {})
    assert_response(:success)
  end
  
  def test_delete
    
    set_subdomain('domininiek')
    
    get(:delete, {}, {})
    assert_response(:success)
    
    post(:delete, {}, {})
    assert_response(:success)
    
    #post(:delete, {:passw}, {})
    #assert_response(:redirect)
    
    
  end

end
