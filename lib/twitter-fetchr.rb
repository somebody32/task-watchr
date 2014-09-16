require "dotenv"
Dotenv.load

require "twitter"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_KEY"]
  config.consumer_secret     = ENV["TWITTER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
end

# there is no saved tweet, so we go deep. Need a key to check that
# also an option to wait for a new tweets without traversing
begin
  # get the first tweet
  tweets = client.mentions_timeline(count: 1)
  puts tweets.map &:text
  max_id = tweets.last.id

  # paginate
  while tweets = client.mentions_timeline(max_id: max_id - 1, count: 5) do
    break if tweets.empty?
    puts tweets.map &:text
    max_id = tweets.last.id
  end
rescue Twitter::Error::TooManyRequests => error
  # what if error encounters while traversing down?
  puts error.rate_limit.reset_in + 1
end


