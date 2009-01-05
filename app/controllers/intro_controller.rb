class IntroController < ApplicationController
  
  def index
    @intro = [
      [:your_style, "Lifestreaming, YOUR style"],
      [:activity, "Activity all over the place"],
      [:web30_enabled, "Web 3.0 Enabled"],
      [:integration, "An Integration Behemoth"],
      [:statistics, "Activity Stats"],
      [:clusters, "Soon: Cluster Streams"]
    ]
    @title = 'Kakuteru - Lifestreaming 3.0'
    unless params[:invite_code].blank?
      redirect_to('/signup?invite_code='+params[:invite_code])
    end
  end
  
  def design
    render(:layout => false)
  end
  
  def signup
    if request.post? && !params[:stream].blank? && !params[:stream][:subdomain].blank?
      redirect_to("http://#{params[:stream][:subdomain]}.#{request.host_with_port}/?invite_code=#{params[:stream][:invite_code]}")
    end
  end
  
end
