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
      paginate_down_starting(all_tweets, count, error_handler)
    end

    def fetch_since(since_id:, count: 200, error_handler: DEFAULT_ERROR_HANDLER)
      paginate_up_starting(since_id, count, error_handler)
    end

    private

    def get_initial_batch(count, error_handler)
      client.mentions_timeline(count: count)
    rescue Twitter::Error::TooManyRequests => e
      error_handler.call(e)
      retry
    end

    def paginate_down_starting(tweets, count, error_handler)
      max_id = tweets.last.id
      begin
        fetch_with_cursor(collector: tweets, max_id: max_id, count: count)
      rescue Twitter::Error::TooManyRequests => e
        error_handler.call(e)
        retry
      end
    end

    def paginate_up_starting(since_id, count, error_handler)
      begin
        fetch_with_cursor(since_id: since_id, count: count)
      rescue Twitter::Error::TooManyRequests => e
        error_handler.call(e)
        retry
      end
    end

    # rubocop:disable Metrics/MethodLength
    def fetch_with_cursor(collector: [], count:, since_id: nil, max_id: nil)
      collector.tap do |all_tweets|
        options = { count: count }
        options.merge!(since_id: since_id) if since_id
        loop do
          # need to substract 1 from max_id to avoid duplicating the last
          # tweet from the previous batch. This is an 'official' hack:
          # https://dev.twitter.com/rest/public/timelines
          options.merge!(max_id: max_id - 1) if max_id
          next_batch = client.mentions_timeline(options)
          all_tweets.concat(next_batch)
          break if next_batch.empty? || next_batch.size < count
          max_id = next_batch.last.id
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
