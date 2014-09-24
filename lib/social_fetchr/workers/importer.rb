require "social_fetchr/fetchr"
require "social_fetchr/workers/updater"

module SocialFetchr
  module Workers
    class Importer
      include Sidekiq::Worker

      def self.perform_inline(credentials)
        new.process(credentials)
      end

      def perform(social_credentials)
        process(social_credentials)
        Updater.enqueue(social_credentials)
      end

      def process(credentials)
        Fetchr.process_all(credentials)
      end
    end
  end
end
