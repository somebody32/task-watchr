Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "adapters#connect"
end
