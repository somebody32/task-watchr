require "social_fetchr/twitter_fetchr"

module SocialFetchr
  module_function

  # TODO
  # 1. implement PostsTrackr
  # 2. implment posts scrubber
  # 3. clean up this mess

  def check_updates(social_credentials)
    client_key = social_credentials.fetch(:client_key)
    tw_client = SocialFetchr::TwitterFetchr.new(social_credentials)

    last_post =
      SocialFetchr::PostsTrackr.last_processed_post(client: client_key)

    if last_post
      new_posts = tw_client.fetch_since(since_id: last_post)
      post_to_store = new_posts.first
      new_posts.reverse.each do |post|
        TaskPostr.post_task post.text
      end
    else
      post_to_store = tw_client.fetch_all(count: 1).first
    end

    if post_to_store
      SocialFetchr::PostsTrackr.store_last_processed_post(
        client: client_key,
        post_id: post_to_store.id
      )
    end
  end
end
