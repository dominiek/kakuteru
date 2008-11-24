require RAILS_ROOT + '/test/test_helper'

class IntroControllerTest < ActionController::TestCase
  def test_index
    get(:index, {}, {})
    assert_response(:success)
    
    post(:index, {:stream => {}}, {})
    assert_response(:success)
    
    post(:index, {:stream => {:subdomain => 'hello', :invite_code => 'hola'}}, {})
    assert_redirected_to('http://hello.test.host/?invite_code=hola')
  end
end
