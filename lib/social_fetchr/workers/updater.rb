require "sidekiq"
require "sidetiq"
require "social_fetchr/fetchr"

module SocialFetchr
  module Workers
    class Updater
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence { daily }

      def perform(social_credentials)
        Fetchr.check_updates(social_credentials)
      end
    end
  end
end
