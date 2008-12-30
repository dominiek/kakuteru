class IntroController < ApplicationController
  
  def index
    @title = 'Kakuteru - Lifestreaming 3.0'
    if request.post? && !params[:stream].blank? && !params[:stream][:subdomain].blank?
      redirect_to("http://#{params[:stream][:subdomain]}.#{request.host_with_port}/?invite_code=#{params[:stream][:invite_code]}")
    end
  end
  
  def invite
    Invite.find_or_create_by_email(params[:invite][:email])
    flash[:notice] = "Thanks! E-mail will be sent on Beta launch!"
    redirect_to(intro_url)
  end
end
