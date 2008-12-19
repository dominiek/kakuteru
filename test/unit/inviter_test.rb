require 'test_helper'

class InviterTest < ActionMailer::TestCase
  tests Inviter
  
  def test_invite
    assert_raises(Inviter::AlreadyInvitedError) do
      invite_mail = Inviter.create_invite(invites(:dominiek))
    end
    invite_mail = Inviter.create_invite(invites(:kirk))
    assert(invite_mail)
    assert_match(invites(:kirk).code, invite_mail.body)
    assert_equal(invites(:kirk).email, invite_mail.to.first)
  end
end
