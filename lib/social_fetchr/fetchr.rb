require "social_fetchr/twitter_fetchr"
require "social_fetchr/post_trackr"
require "social_fetchr/post_scrubbr"

module SocialFetchr
  class Fetchr
    def self.check_updates(social_credentials)
      client_key = social_credentials.fetch(:client_key)
      tw_adapter = initialize_social_adapter(social_credentials)

      post_to_store = check_and_process_posts(client_key, tw_adapter)

      return unless post_to_store
      store_last_post(client_key, post_to_store)
    end


    def self.initialize_social_adapter(credentials)
      SocialFetchr::TwitterFetchr.new(credentials)
    end

    def self.check_and_process_posts(client_key, adapter)
      last_post =
        SocialFetchr::PostTrackr.last_processed_post(client: client_key)

      post_to_store = if last_post
                        process_new_posts_since(last_post, adapter)
                      else
                        get_latest_post(adapter)
                      end
      post_to_store
    end

    def self.get_latest_post(adapter)
      adapter.fetch_all(count: 1).first
    end

    def self.process_new_posts_since(last_post, adapter)
      new_posts = adapter.fetch_since(since_id: last_post)
      new_posts.reverse.each do |post|
        TaskPostr.post_task SocialFetchr::PostScrubbr.scrub(post.text)
      end
      new_posts.first
    end

    def self.store_last_post(client_key, post)
      SocialFetchr::PostTrackr.store_last_processed_post(
        client: client_key,
        post_id: post.id
      )
    end
  end
end
