require "dotenv"
Dotenv.load

require "social_fetchr/twitter_fetchr"

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
  end

  it "handles errors and rate limits"
  it "returns all new tweets starting from passed one"
end
