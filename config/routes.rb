Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  get "/auth/twitter/callback", to: "fetchr_social#connect"
  get "/auth/failure", to: "fetchr_social#failure"

  scope module: :adapters do
    resource :redbooth_settings, only: [:edit, :update]
    get "/auth/redbooth/callback", to: "redbooth_settings#connect"
  end
  post "fetchr/start", to: "fetchr_status#start", as: "start_fetchr"
  post(
    "fetchr/import_and_start",
    to: "fetchr_status#import_and_start",
    as: "import_and_start_fetchr"
  )
  root to: "fetchr_status#show"
end
