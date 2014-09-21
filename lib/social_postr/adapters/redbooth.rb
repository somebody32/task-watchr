require "faraday"
require "json"

module SocialPostr
  module Adapters
    module Errors
      class ExpiredToken < StandardError; end
    end
    class Redbooth
      attr_reader :adapter_settings
      BASE_REQUEST_URL="https://redbooth.com"
      ENDPOINT="/api/3/tasks"

      def initialize(adapter_settings)
        @adapter_settings = adapter_settings
      end

      def post_task(task_text)
        response = Faraday.post do |req|
          req.url BASE_REQUEST_URL + ENDPOINT
          req.headers["Authorization"] = "Bearer #{adapter_settings[:token]}"
          req.body = {
            name: task_text,
            description: adapter_settings.fetch(:task_description){ "" },
            is_private: adapter_settings.fetch(:task_private){ false },
            task_list_id: adapter_settings.fetch(:task_list_id),
            project_id: adapter_settings.fetch(:project_id)
          }
        end
        if response.status == 401 && response.headers["www-authenticate"].match(/The access token expired/)
          raise SocialPostr::Adapters::Errors::ExpiredToken
        end
        JSON.parse(response.body)
      end
    end
  end
end
