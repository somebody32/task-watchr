require "dotenv"
Dotenv.load

require "social_fetchr/twitter_fetchr"
require "webmock/rspec"

describe SocialFetchr::TwitterFetchr do
  subject do
    described_class.new(
      app_key:       ENV["TWITTER_KEY"],
      app_secret:    ENV["TWITTER_SECRET"],
      client_key:    ENV["TWITTER_ACCESS_TOKEN"],
      client_secret: ENV["TWITTER_ACCESS_SECRET"]
    )
  end

  let(:all_tweets_texts) do
    [
      "@task_watchr_bot test tweet 6",
      "@task_watchr_bot test tweet 5",
      "@task_watchr_bot test tweet 4",
      "@task_watchr_bot test tweet 3",
      "@task_watchr_bot test tweet 2",
      "@task_watchr_bot test tweet 1"
    ]
  end

  let(:mentions_endpoint) do
    'https://api.twitter.com/1.1/statuses/mentions_timeline.json'
  end

  context "fetching all" do
    it "returns all" do
      VCR.use_cassette("twitter") do
        tweets = subject.fetch_all
        expect(tweets.map(&:text)).to eql all_tweets_texts
      end
    end

    it "paginates using count option" do
      VCR.use_cassette("twitter_with_pagination") do
        tweets = subject.fetch_all(count: 1)
        expect(tweets.map(&:text)).to eql all_tweets_texts
      end
    end

    it "handles the rate limits on the first try" do
      stub_request(
        :any,
        mentions_endpoint
      ).with(query: { count: 200 })
       .to_raise(Twitter::Error::TooManyRequests)

      error_handler = ->(error) do
        stub_request(
          :any,
          mentions_endpoint
        ).with(query: { count: 200 })
         .to_return(
          body: '{}',
          headers: {content_type: 'application/json; charset=utf-8'}
        )
      end

      subject.fetch_all(error_handler: error_handler)
    end

    it "handles the rate limits when paging" do
      stub_request(
        :any,
        mentions_endpoint
      ).with(query: { count: 1 })
       .to_return(
          body: '[{"id":1,"text":"@task_watchr_bot test tweet 6"}]',
          headers: {content_type: 'application/json; charset=utf-8'}
       )
      stub_request(
        :any,
        mentions_endpoint
      ).with(query: { count: 1, max_id: 0 })
       .to_raise(Twitter::Error::TooManyRequests)

      error_handler = ->(error) do
        stub_request(
          :any,
          mentions_endpoint
        ).with(query: { count: 1, max_id: 0 })
         .to_return(
          body: '{}',
          headers: {content_type: 'application/json; charset=utf-8'}
        )
      end

      subject.fetch_all(count: 1, error_handler: error_handler)
    end
  end

  it "returns all new tweets starting from passed one"
end
