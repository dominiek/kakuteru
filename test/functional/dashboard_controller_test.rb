require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
    set_subdomain(streams(:dominiek).subdomain)
  end
  
  def test_forgot_password_fail
    old_change_password_token = streams(:dominiek).change_password_token
    post(:forgot_password, {:email => 'blabla'}, {})
    assert_response(:success)
    assert(!assigns(:stream).errors.blank?)
    assert_equal(old_change_password_token, assigns(:stream).change_password_token)
  end
  
  def test_forgot_password_success
    old_change_password_token = streams(:dominiek).change_password_token
    get(:forgot_password, {}, {})
    assert_response(:success)

    post(:forgot_password, {:email => streams(:dominiek).email}, {})
    assert_response(:success)
    assert(assigns(:stream).errors.blank?)
    assert(!ActionMailer::Base.deliveries.blank?)
    assert_not_equal(old_change_password_token, assigns(:stream).change_password_token)
  end
  
  def test_reset_password
    get(:reset_password, {}, {})
    assert_response(:success)
    
    post(:reset_password, {:new_password => 'hello', :new_password_repeat => 'hello', :token => 'INVALID'}, {})
    assert_response(:success)
    assert(assigns(:stream).errors[:change_password_token])
    
    post(:reset_password, {:new_password => 'helloaa', :new_password_repeat => 'hello', :token => streams(:dominiek).change_password_token}, {})
    assert_response(:success)
    assert(assigns(:stream).errors[:password])
    
    old_password = streams(:dominiek).password
    post(:reset_password, {:new_password => 'hello', :new_password_repeat => 'hello', :token => streams(:dominiek).change_password_token}, {})
    assert_response(:redirect)
    assert(assigns(:stream).errors.blank?)
    assert_not_equal(old_password, streams(:dominiek).reload.password)
    assert_equal(assigns(:stream).subdomain, session[:authenticated_subdomain])
  end
  
end
