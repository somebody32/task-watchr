module SocialPostr
  module Adapters
    module Errors
      class ExpiredToken < StandardError; end
      class UnexpectedAPIResponse < StandardError
        attr_accessor :api_response
        DEFAULT_MESSAGE = "Unexpected API Response. Saved to api_response attr"

        def initialize(message: DEFAULT_MESSAGE, api_response: nil)
          super(message)
          self.api_response = api_response
        end
      end
    end
  end
end
