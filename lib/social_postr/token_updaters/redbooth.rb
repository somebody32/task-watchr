require "omniauth-redbooth"

module SocialPostr
  module TokenUpdaters
    module Redbooth
      module_function

      def update_token(access_token, refresh_token)
        client_id = ENV['REDBOOTH_KEY']
        client_secret = ENV['REDBOOTH_SECRET']
        oauth2_urls = {
          site: 'https://redbooth.com/api/3',
          token_url: 'https://redbooth.com/oauth2/token',
          authorize_url: 'https://redbooth.com/oauth2/authorize'
        }
        oauth2_client = OAuth2::Client.new(client_id, client_secret, oauth2_urls)
        access_token = OAuth2::AccessToken.new(oauth2_client, access_token)
        refresh_access_token_obj = OAuth2::AccessToken.new(oauth2_client, access_token.token, {'refresh_token' => refresh_token})
        access_token = refresh_access_token_obj.refresh!
        {token: access_token.token, refresh_token: access_token.refresh_token }
      end
    end
  end
end
