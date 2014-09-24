Rails.application.routes.draw do
  get "/auth/twitter/callback", to: "fetchr_social#connect"
  get "/auth/failure", to: "fetchr_social#failure"

  scope module: :adapters do
    resource :redbooth_settings, only: [:edit, :update]
    get "/auth/redbooth/callback", to: "redbooth_settings#connect"
  end

  root to: "fetchr_status#show"
end
