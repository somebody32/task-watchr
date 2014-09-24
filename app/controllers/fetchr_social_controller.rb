class FetchrSocialController < ApplicationController
  def connect
    settings = {
      name: request.env["omniauth.auth"][:info][:nickname],
      client_key: request.env["omniauth.auth"][:credentials][:token],
      client_secret: request.env["omniauth.auth"][:credentials][:secret]
    }
    FetchrSocialSettings.new(settings).save
    redirect_to :root
  end

  def failure
    flash[:error] = "#{params[:strategy].titleize} Connection Failed"
    redirect_to :root
  end
end
