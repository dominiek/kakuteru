require RAILS_ROOT + '/test/test_helper'
require 'md5'

class InviteTest < ActiveSupport::TestCase
  
  def test_generate_invite_codes
    Invite.generate_codes!
    assert_equal(MD5.hexdigest(invites(:dominiek).email), invites(:dominiek).code)
    assert_equal(MD5.hexdigest(invites(:peter).email), invites(:peter).code)
    assert_equal(nil, invites(:peter).used_for_stream)
    assert_equal(false, invites(:peter).is_used?)
  end
  
end
