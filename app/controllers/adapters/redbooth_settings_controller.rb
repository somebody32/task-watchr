module Adapters
  class RedboothSettingsController < ApplicationController
    def edit
      @settings = RedboothSettings.fetch
      token = @settings.token
      task_lists_raw = Faraday.get do |req|
        req.url "https://redbooth.com/api/3/task_lists"
        req.headers["Authorization"] = "Bearer #{token}"
      end
      @settings.task_list_id = [@settings.task_list_id, @settings.project_id].join("/")
      logger.info JSON.parse(task_lists_raw.body)
      @task_lists = JSON.parse(task_lists_raw.body).map do |t|
        [t["name"], [t["id"], t["project_id"]].join("/")]
      end
    end

    def update
      settings = RedboothSettings.fetch.attributes
      params_ready = settings.merge(params[:adapters_redbooth_settings])
      settings = RedboothSettings.new(params_ready)
      task_list_id, project_id = settings.task_list_id.split("/")
      settings.task_list_id = task_list_id
      settings.project_id = project_id
      settings.save
      redirect_to :root
    end

    def connect
      credentials = request.env["omniauth.auth"]["credentials"]

      RedboothSettings.new(
        token: credentials["token"],
        refresh_token: credentials["refresh_token"]
      ).save

      redirect_to :root
    end
  end
end
