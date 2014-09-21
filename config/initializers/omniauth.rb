Rails.application.config.middleware.use OmniAuth::Builder do
  provider :redbooth, ENV["REDBOOTH_KEY"], ENV["REDBOOTH_SECRET"]
end
