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

      start_from = all_tweets.last.id
      all_tweets + paginate_down_starting(start_from, count, error_handler)
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

    def paginate_down_starting(max_id, count, error_handler)
      paginate({ max_id: max_id }, count, error_handler)
    end

    def paginate_up_starting(since_id, count, error_handler)
      paginate({ since_id: since_id }, count, error_handler)
    end

    def paginate(cursor, count, error_handler)
      fetch_with_cursor(cursor, count)
    rescue Twitter::Error::TooManyRequests => e
      error_handler.call(e)
      retry
    end

    # it is possible to split this method more, but I don't think that it
    # make it easier to understand
    # rubocop:disable Metrics/MethodLength
    def fetch_with_cursor(cursor = {}, count)
      since_id = cursor[:since_id]
      max_id   = cursor[:max_id]
      [].tap do |all_tweets|
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
