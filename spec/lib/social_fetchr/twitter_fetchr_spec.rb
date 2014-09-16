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

  it "returns all the tweets" do
    VCR.use_cassette("twitter") do
      expect(subject.fetch_all.size).to eql 6
    end
  end

  it "returns all new tweets starting from passed one"
end
