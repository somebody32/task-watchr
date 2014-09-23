require "sidekiq"
require "social_fetchr/fetchr"

module SocialFetchr
  module Workers
    class Updater
      include Sidekiq::Worker
      DEFAULT_INTERVAL = 10 * 60

      def self.perform_inline(credentials)
        new.process_job(credentials)
      end

      def perform(credentials)
        process_job(credentials)
      ensure
        self.class.perform_in(DEFAULT_INTERVAL, credentials)
      end

      def process_job(credentials)
        Fetchr.check_updates(credentials)
      end
    end
  end
end
