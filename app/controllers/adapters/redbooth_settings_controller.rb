module Adapters
  class RedboothSettingsController < ApplicationController
    def edit
    end

    def update
    end

    def connect
      credentials = request.env["omniauth.auth"]["credentials"]

      RedboothSettings.save(
        token: credentials["token"],
        refresh_token: credentials["refresh_token"]
      )

      redirect_to :root
    end
  end
end
