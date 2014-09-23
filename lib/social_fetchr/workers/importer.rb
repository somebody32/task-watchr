require "social_fetchr/fetchr"

module SocialFetchr
  module Workers
    class Importer
      include Sidekiq::Worker

      def self.perform_inline(credentials)
        new.perform(credentials)
      end

      def perform(social_credentials)
        Fetchr.process_all(social_credentials)
      end
    end
  end
end
