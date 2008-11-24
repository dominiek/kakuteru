require RAILS_ROOT + '/test/test_helper'

class StreamTest < ActiveSupport::TestCase
  
  def test_verify_invite_code!
    Invite.generate_codes!
    stream = streams(:peter)
    assert_equal(false, stream.verify_invite_code!('BULLSHIT'))
    assert_equal(false, stream.verify_invite_code!(invites(:dominiek).code))
    assert(!stream.errors.blank?)
    assert_equal(true, stream.verify_invite_code!(invites(:peter).code))
    assert_equal(stream.subdomain, invites(:peter).reload.used_for_stream)
  end
  
end
