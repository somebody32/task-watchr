Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "adapters#connect"
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
