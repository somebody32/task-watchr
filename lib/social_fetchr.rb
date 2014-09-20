require "social_fetchr/twitter_fetchr"
require "social_fetchr/post_trackr"
require "social_fetchr/post_scrubbr"

module SocialFetchr
  module_function

  # TODO
  # 3. clean up this mess

  def check_updates(social_credentials)
    client_key = social_credentials.fetch(:client_key)
    tw_client = SocialFetchr::TwitterFetchr.new(social_credentials)

    last_post =
      SocialFetchr::PostTrackr.last_processed_post(client: client_key)

    if last_post
      new_posts = tw_client.fetch_since(since_id: last_post)
      post_to_store = new_posts.first
      new_posts.reverse.each do |post|
        TaskPostr.post_task SocialFetchr::PostScrubbr.scrub(post.text)
      end
    else
      post_to_store = tw_client.fetch_all(count: 1).first
    end

    if post_to_store
      SocialFetchr::PostTrackr.store_last_processed_post(
        client: client_key,
        post_id: post_to_store.id
      )
    end
  end
end
