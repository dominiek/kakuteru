require 'test_helper'

class MailerTest < ActionMailer::TestCase
  tests Mailer
  
  def test_forgot_password
    mail = Mailer.create_forgot_password(streams(:dominiek))
    assert_match(streams(:dominiek).change_password_token, mail.body)
    assert_equal(streams(:dominiek).email, mail.to.first)
  end
  
end
