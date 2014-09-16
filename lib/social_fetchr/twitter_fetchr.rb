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

    def fetch_all(count: 200)
      all_tweets = client.mentions_timeline(count: count)
      return all_tweets if all_tweets.size < count

      max_id = all_tweets.last.id

      loop do
        # need to substract 1 from max_id to avoid duplicating the last
        # tweet from the previous batch. This is an 'official' hack:
        # https://dev.twitter.com/rest/public/timelines
        next_batch = client.mentions_timeline(max_id: max_id - 1, count: count)
        all_tweets.concat(next_batch)
        break if next_batch.empty? || next_batch.size < count
        max_id = next_batch.last.id
      end

      all_tweets
    end
  end
end
