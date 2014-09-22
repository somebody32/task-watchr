require "redis"

module SocialPostr
  module Adapters
    module SettingsRepository
      module_function

      def fetch(adapter_name)
        db_client.hgetall(adapter_db_key(adapter_name))
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
      private_class_method :db_client, :adapter_db_key
    end
  end
end
