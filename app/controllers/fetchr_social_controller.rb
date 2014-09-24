class FetchrSocialController < ApplicationController
  def connect
    # move this to a service
    settings = {
      name: request.env["omniauth.auth"][:info][:nickname],
      client_key: request.env["omniauth.auth"][:credentials][:token],
      client_secret: request.env["omniauth.auth"][:credentials][:secret]
    }
    if FetchrSocialSettings.new(settings).save
      flash[:info] = "Twitter Connected!"
    else
      flash[:error] = "Twitter Connection Failed"
    end
    redirect_to :root
  end

  def failure
    flash[:error] = "#{params[:strategy].titleize} Connection Failed"
    redirect_to :root
  end
end
