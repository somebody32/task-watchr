module Adapters
  class RedboothSettingsDecorator
    def self.decorated_settings
      new.prepare_task_lists
    end

    def initialize
      @settings = RedboothSettings.fetch
    end

    def prepare_task_lists
      encrypt_current_task_list!
      @settings
    end

    private

    def encrypt_current_task_list!
      encrypted_list = [@settings.task_list_id, @settings.project_id].join("/")
      @settings.task_list_id = encrypted_list
    end
  end
end
