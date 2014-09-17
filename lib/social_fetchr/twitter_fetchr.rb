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

    DEFAULT_ERROR_HANDLER = ->(error) { sleep error.rate_limit.reset_in + 1 }

    def fetch_all(count: 200, error_handler: DEFAULT_ERROR_HANDLER)
      all_tweets = get_initial_batch(count, error_handler)
      return all_tweets if all_tweets.size < count
      paginate_deep_starting(all_tweets, count, error_handler)
    end

    private

    def get_initial_batch(count, error_handler)
      client.mentions_timeline(count: count)
    rescue Twitter::Error::TooManyRequests => e
      error_handler.call(e)
      retry
    end

    # it is possible to split this method even more, but for my taste
    # this will introduce more eye-hops when grasping on it.
    # And it is a very easy one, so it is better to disable rubocop's warnings
    # rubocop:disable Metrics/MethodLength
    def paginate_deep_starting(tweets, count, error_handler)
      max_id = tweets.last.id
      begin
        loop do
          # need to substract 1 from max_id to avoid duplicating the last
          # tweet from the previous batch. This is an 'official' hack:
          # https://dev.twitter.com/rest/public/timelines
          next_batch = client.mentions_timeline(
            max_id: max_id - 1,
            count: count
          )
          tweets.concat(next_batch)
          break if next_batch.empty? || next_batch.size < count
          max_id = next_batch.last.id
        end
        tweets
      rescue Twitter::Error::TooManyRequests => e
        error_handler.call(e)
        retry
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
