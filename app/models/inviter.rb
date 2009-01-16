class Inviter < ActionMailer::Base
  class AlreadyInvitedError < StandardError; end
  
  def invite(invite)
    raise AlreadyInvitedError.new if invite.mail_sent?
    recipients(invite.email)
    from("no-reply@kakuteru.com")
    subject("Your Kakuteru.com invite!")
    invite.update_attribute(:mail_sent, true)
    body(:invite => invite)
  end

end
