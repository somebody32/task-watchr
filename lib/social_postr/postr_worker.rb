require "sidekiq"
require "social_postr/adapters/all"
require "social_postr/adapters/errors"
require "social_postr/adapters/settings_repository"
require "social_postr/token_updaters/all"

module SocialPostr
  class PostrWorker
    attr_reader :adapter_name
    include Sidekiq::Worker

    def perform(adapter_name, task)
      @adapter_name = adapter_name
      settings = Adapters::SettingsRepository.fetch(adapter_name)
      adapter = initialize_adapter(settings)
      adapter.post_task(task)
    rescue Adapters::Errors::ExpiredToken
      update_tokens(settings)
      retry
    end

    private

    def initialize_adapter(settings)
      full_adapter_name = "Adapters::#{adapter_name.capitalize}"
      adapter_class = SocialPostr.const_get(full_adapter_name)
      @adapter = adapter_class.new(settings)
    end

    def update_tokens(settings)
      token_updater = initialize_token_updater
      new_tokens = token_updater.update_token(settings)
      Adapters::SettingsRepository.save(adapter_name, new_tokens)
    end

    def initialize_token_updater
      full_token_updater_name = "TokenUpdaters::#{adapter_name.capitalize}"
      @token_updater = SocialPostr.const_get(full_token_updater_name)
    end
  end
end
