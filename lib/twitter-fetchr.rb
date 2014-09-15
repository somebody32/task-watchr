require "dotenv"
Dotenv.load

require "twitter"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["TWITTER_KEY"]
  config.consumer_secret     = ENV["TWITTER_SECRET"]
  config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
end

puts client.mentions_timeline(trim_user: true).map &:text
