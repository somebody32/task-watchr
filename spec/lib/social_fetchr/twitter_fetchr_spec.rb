require "social_fetchr/twitter_fetchr"
require "webmock/rspec"

VCR.configure do |c|
  %w(
    TWITTER_KEY
    TWITTER_SECRET
    TWITTER_ACCESS_TOKEN
    TWITTER_ACCESS_SECRET
  ).each do |const|
    c.filter_sensitive_data("<#{const}>") { ENV[const] }
  end
end

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
    "https://api.twitter.com/1.1/statuses/mentions_timeline.json"
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
      # imitate rate limit on initial request
      imitate_rate_limit(count: 200)

      error_handler = lambda do |_|
        # disabling ratelimiting and imitating empty response
        imitate_response({ count: 200 }, "{}")
      end

      expect(subject.fetch_all(error_handler: error_handler)).to be_empty
    end

    it "handles the rate limits when paging" do
      # imitating first successfull response
      imitate_response(
        { count: 1 },
        '[{"id":1,"text":"@task_watchr_bot test tweet 6"}]'
      )

      # and the next one will fail with rate limit
      imitate_rate_limit(count: 1, max_id: 0)

      error_handler = lambda do |_|
        # and then rate limit pass and twitter returns empty response
        imitate_response({ count: 1, max_id: 0 }, "{}")
      end

      expect(
        subject.fetch_all(count: 1, error_handler: error_handler).map(&:text)
      ).to eql(["@task_watchr_bot test tweet 6"])
    end
  end

  context "fetching new tweets" do
    let(:tweet_4_id) { 511_758_804_300_464_128 }

    it "returns all new tweets starting from passed one" do
      VCR.use_cassette("twitter_fetching_since") do
        expect(
          subject.fetch_since(since_id: tweet_4_id).map(&:text)
        ).to eql([
          "@task_watchr_bot test tweet 6",
          "@task_watchr_bot test tweet 5"
        ])
      end
    end

    it "paginates if there are more tweets than count var" do
      VCR.use_cassette("twitter_fetching_since_paginate") do
        expect(
          subject.fetch_since(since_id: tweet_4_id, count: 1).map(&:text)
        ).to eql([
          "@task_watchr_bot test tweet 6",
          "@task_watchr_bot test tweet 5"
        ])
      end
    end

    it "handles rate limiting" do
      # imitating first successfull response
      imitate_response(
        { count: 1, since_id: tweet_4_id },
        '[{"id":1,"text":"@task_watchr_bot test tweet 6"}]'
      )

      # and the next one will fail with rate limit
      imitate_rate_limit(count: 1, max_id: 0, since_id: tweet_4_id)

      error_handler = lambda do |_|
        # and then rate limit pass and twitter returns empty response
        imitate_response({ count: 1, max_id: 0, since_id: tweet_4_id }, "{}")
      end

      expect(
        subject.fetch_since(
          since_id: tweet_4_id,
          count: 1,
          error_handler: error_handler
        ).map(&:text)
      ).to eql(["@task_watchr_bot test tweet 6"])
    end
  end

  def imitate_rate_limit(query_params)
    stub_request(
      :any,
      mentions_endpoint
    )
    .with(query: query_params)
    .to_raise(Twitter::Error::TooManyRequests)
  end

  def imitate_response(query_params, body)
    stub_request(
      :any,
      mentions_endpoint
    )
    .with(query: query_params)
    .to_return(
      body: body,
      headers: { content_type: "application/json; charset=utf-8" }
    )
  end
end
