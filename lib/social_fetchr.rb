require "social_fetchr/fetchr"

module SocialFetchr
  module_function

  def check_updates(social_credentials)
    SocialFetchr::Fetchr.check_updates(social_credentials)
  end
end
