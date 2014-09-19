require "redis"

module SocialFetchr
  module PostTrackr
    module_function

    def last_processed_post(client:)
      db_client.get("#{client}_last_twitter_message_id")
    end

    def store_last_processed_post(client:, post_id:)
      db_client.set("#{client}_last_twitter_message_id", post_id)
    end

    def db_client
      Redis.new(url: ENV["REDIS_URL"])
    end
    private_class_method :db_client
  end
end
