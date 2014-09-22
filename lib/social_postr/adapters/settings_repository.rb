require "redis"

module SocialPostr
  module Adapters
    module SettingsRepository
      module_function

      def fetch(adapter_name)
        raw_settings = db_client.hgetall(adapter_db_key(adapter_name))
        symbolize_keys(raw_settings)
      end

      def save(adapter_name, settings = {})
        db_client.mapped_hmset(adapter_db_key(adapter_name), settings)
      end

      def db_client
        Redis.new(url: ENV["REDIS_URL"])
      end

      def adapter_db_key(adapter_name)
        "postr_#{adapter_name}_settings"
      end

      # I do not want to add dependency on ActiveSupport just for that
      def symbolize_keys(hash)
        Hash[hash.map { |(k, v)| [k.to_sym, v] }]
      end
      private_class_method :db_client, :adapter_db_key, :symbolize_keys
    end
  end
end
