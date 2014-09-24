require "sidekiq/api"
class ResetController < ApplicationController
  def reset
    Sidekiq::Queue.new.clear
    Sidekiq::Queue.new(SocialFetchr::Workers::Importer::QUEUE).clear
    Sidekiq::ScheduledSet.new.clear
    redis = $redis
    redis.del(:postr_redbooth_settings)
    redis.del(FetchrSocialSettings::DB_KEY)

    redirect_to :root
  end
end
