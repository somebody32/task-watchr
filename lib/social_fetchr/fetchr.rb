require "social_fetchr/twitter_fetchr"
require "social_fetchr/post_trackr"
require "social_fetchr/post_scrubbr"
require "social_postr"

module SocialFetchr
  class Fetchr
    attr_reader :client_key, :social_adapter
    private_class_method :new

    def self.check_updates(social_credentials)
      new(social_credentials).check_and_process_updates
    end

    def self.process_all(social_credentials)
      new(social_credentials).fetch_and_process_all
    end

    def initialize(social_credentials)
      social_credentials = symbolize_keys(social_credentials)
      @client_key = social_credentials.fetch(:client_key)
      @social_adapter = initialize_social_adapter(social_credentials)
    end

    def check_and_process_updates
      last_processed_post = process_new_posts
      store_last_post(last_processed_post)
    end

    def fetch_and_process_all
      last_processed_post = process_all_posts
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

    def process_all_posts
      process_posts(social_adapter.fetch_all)
    end

    def latest_post
      social_adapter.fetch_all(count: 1).first
    end

    def process_new_posts_since(last_post)
      process_posts(social_adapter.fetch_since(since_id: last_post))
    end

    def process_posts(posts)
      posts.reverse.each do |post|
        SocialPostr.post_task SocialFetchr::PostScrubbr.scrub(post.text)
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

    def symbolize_keys(hash)
      Hash[hash.map { |(k, v)| [k.to_sym, v] }]
    end
  end
end
