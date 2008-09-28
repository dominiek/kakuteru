class IntroController < ApplicationController
  
  def invite
    Invite.find_or_create_by_email(params[:invite][:email])
    flash[:notice] = "Thanks! E-mail will be sent on Beta launch!"
    redirect_to(intro_url)
  end
end
