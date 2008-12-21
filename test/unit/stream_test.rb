require 'test_helper'

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
  
  def test_feedburner_username
    stream = Stream.new
    assert_equal(nil, stream.feedburner_username)
    stream = Stream.new(:feedburner_feed_url => "http://feeds.feedburner.com/dominiek")
    assert_equal('dominiek', stream.feedburner_username)
  end
  
end
