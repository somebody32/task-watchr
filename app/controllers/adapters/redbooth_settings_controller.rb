module Adapters
  class RedboothSettingsController < ApplicationController
    def edit
      @settings = RedboothSettingsDecorator.decorated_settings
      # omg network request in the controller!
      # I could cache the task list initialy when getting oauth token,
      # but this will not update automatically when new task lists are created
      # The best way is to make an async-request from the client,
      # but the current timebox limited me from doing so
      @task_lists = RedboothTaskListRetriever.fetch_task_lists(@settings.token)
    end

    def update
      RedboothSettingsRepository.update(params[:adapters_redbooth_settings])
      redirect_to :root
    end

    def connect
      credentials = request.env["omniauth.auth"]["credentials"]

      RedboothSettingsRepository.update_tokens(
        token: credentials["token"],
        refresh_token: credentials["refresh_token"]
      )

      redirect_to :root
    end
  end
end
