class AdaptersController < ApplicationController
  def connect
    render text: request.env["omniauth.auth"].inspect
  end
end
