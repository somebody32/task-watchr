require "omniauth-redbooth"

module SocialPostr
  module TokenUpdaters
    module Redbooth
      URLS = {
        site: "https://redbooth.com/api/3",
        token_url: "https://redbooth.com/oauth2/token",
        authorize_url: "https://redbooth.com/oauth2/authorize"
      }

      module_function

      def update_token(credentials)
        client_id     = credentials.fetch(:key)
        client_secret = credentials.fetch(:secret)
        token         = credentials.fetch(:token)
        refresh_token = credentials.fetch(:refresh_token)

        oauth2_client = OAuth2::Client.new(client_id, client_secret, URLS)
        new_token = request_new_token(oauth2_client, token, refresh_token)

        { token: new_token.token, refresh_token: new_token.refresh_token }
      end

      def request_new_token(client, current_token, refresh_token)
        access_token = OAuth2::AccessToken.new(client, current_token)
        token_refresher = OAuth2::AccessToken.new(
          client,
          access_token.token,
          "refresh_token" => refresh_token
        )
        token_refresher.refresh!
      end
      private_class_method :request_new_token
    end
  end
end
