require "social_fetchr/twitter_fetchr"
require "social_fetchr/post_trackr"
require "social_fetchr/post_scrubbr"

module SocialFetchr
  class Fetchr
    attr_reader :client_key, :social_adapter

    def self.check_updates(social_credentials)
      new(social_credentials).check_and_process_updates
    end

    def initialize(social_credentials)
      @client_key = social_credentials.fetch(:client_key)
      @social_adapter = initialize_social_adapter(social_credentials)
    end

    def check_and_process_updates
      last_processed_post = process_new_posts
      store_last_post(last_processed_post)
    end

    private

    def initialize_social_adapter(credentials)
      SocialFetchr::TwitterFetchr.new(credentials)
    end

    def process_new_posts
      last_post =
        SocialFetchr::PostTrackr.last_processed_post(client: client_key)

      if last_post
        process_new_posts_since(last_post)
      else
        latest_post
      end
    end

    def latest_post
      social_adapter.fetch_all(count: 1).first
    end

    def process_new_posts_since(last_post)
      process_posts(social_adapter.fetch_since(since_id: last_post))
    end

    def process_posts(posts)
      posts.reverse.each do |post|
        TaskPostr.post_task SocialFetchr::PostScrubbr.scrub(post.text)
      end
      posts.first
    end

    def store_last_post(post)
      return unless post
      SocialFetchr::PostTrackr.store_last_processed_post(
        client: client_key,
        post_id: post.id
      )
    end
  end
end
