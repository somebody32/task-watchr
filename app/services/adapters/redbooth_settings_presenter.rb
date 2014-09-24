module Adapters
  class RedboothSettingsPresenter
    CLIENT_FIELDS = [:token, :refresh_token]
    REQUIRED_FIELDS = CLIENT_FIELDS + [
      :key,
      :secret,
      :project_id,
      :task_list_id
    ]

    def self.decorated_settings
      new.prepare_task_lists
    end

    def self.fully_satisfied?
      new.settings_fullfilled?
    end

    def self.connected?
      new.client_fields_fullfilled?
    end

    def initialize
      @settings = RedboothSettings.fetch
    end

    def prepare_task_lists
      encrypt_current_task_list!
      @settings
    end

    def settings_fullfilled?
      @settings.attributes.values_at(*REQUIRED_FIELDS).all?
    end

    def client_fields_fullfilled?
      @settings.attributes.values_at(*CLIENT_FIELDS).all?
    end

    private

    def encrypt_current_task_list!
      encrypted_list = [@settings.task_list_id, @settings.project_id].join("/")
      @settings.task_list_id = encrypted_list
    end
  end
end
