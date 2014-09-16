require "twitter"

module SocialFetchr
  class TwitterFetchr
    attr_reader :client

    def initialize(app_key:, app_secret:, client_key:, client_secret:)
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = app_key
        config.consumer_secret     = app_secret
        config.access_token        = client_key
        config.access_token_secret = client_secret
      end
    end

    def fetch_all
      client.mentions_timeline
    end
  end
end
