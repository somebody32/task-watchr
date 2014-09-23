require "sidekiq"
require "sidekiq/api"
require "social_fetchr/fetchr"

module SocialFetchr
  module Workers
    class Updater
      DEFAULT_INTERVAL = 10 * 60
      QUEUE = :social_updater
      include Sidekiq::Worker
      sidekiq_options queue: QUEUE

      def self.running?
        !Sidekiq::Queue.new(QUEUE).size.zero? ||
        Sidekiq::ScheduledSet.new.any? { |job| job.klass == name }
      end

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
