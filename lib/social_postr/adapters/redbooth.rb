require "social_postr/adapters/errors"
require "faraday"
require "json"

module SocialPostr
  module Adapters
    class Redbooth
      attr_reader :adapter_settings, :api_response
      BASE_REQUEST_URL = "https://redbooth.com"
      ENDPOINT = "/api/3/tasks"

      def initialize(settings)
        @adapter_settings = parse_adapter_settings(settings)
      end

      def post_task(task_text)
        make_task_api_call(task_text)
        check_sane_api_response
        parsed_response
      end

      private

      def parse_adapter_settings(settings)
        adapter_settings = {
          token:        settings.fetch(:token),
          project_id:   settings.fetch(:project_id),
          task_list_id: settings.fetch(:task_list_id),
          is_private:   settings.fetch(:task_private) { false }
        }
        if settings[:task_description] && settings[:task_description].length > 0
          adapter_settings.merge!(description: settings[:task_description])
        end
        adapter_settings
      end

      def make_task_api_call(task_text)
        @api_response = Faraday.post do |req|
          req.url BASE_REQUEST_URL + ENDPOINT
          req.headers["Authorization"] = "Bearer #{adapter_settings[:token]}"
          req.body = adapter_settings.merge(name: task_text)
        end
      end

      def check_sane_api_response
        return if api_response.status == 201
        if token_expired?
          fail Errors::ExpiredToken
        else
          puts api_response.inspect
          fail Errors::UnexpectedAPIResponse.new(api_response: api_response)
        end
      end

      def token_expired?
        api_response.status == 401 &&
          api_response
            .headers["www-authenticate"]
            .match(/The access token expired/)
      end

      def parsed_response
        JSON.parse(api_response.body)
      end
    end
  end
end
