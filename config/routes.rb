Rails.application.routes.draw do
  scope module: :adapters do
    resource :redbooth_settings, only: [:edit, :update]
    get "/auth/redbooth/callback", to: "redbooth_settings#connect"
  end
  root to: "fetchr_status#show"
end
