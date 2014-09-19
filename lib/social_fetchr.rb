require "social_fetchr/twitter_fetchr"

module SocialFetchr
  module_function

  def check_updates(social_credentials)
    client_key = social_credentials.fetch(:client_key)
    SocialFetchr::PostsTrackr.last_processed_post(client: client_key)
    tw_client = SocialFetchr::TwitterFetchr.new(social_credentials)
    tweets = tw_client.fetch_all(count: 1)
    SocialFetchr::PostsTrackr.store_last_processed_post(
      client: client_key,
      post_id: tweets.first.id
    )
  end
end
