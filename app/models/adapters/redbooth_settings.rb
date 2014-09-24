module Adapters
  class RedboothSettings
    include ActiveModel::Model

    attr_accessor :project_id, :task_list_id, :task_private,
                  :task_description, :token, :refresh_token, :key, :secret

    def self.fetch
      new(SocialPostr::Adapters::SettingsRepository.fetch(:redbooth))
    end

    def save
      SocialPostr::Adapters::SettingsRepository.save(:redbooth, attributes)
    end

    def attributes
      {
        key:           ENV["REDBOOTH_KEY"],
        secret:        ENV["REDBOOTH_SECRET"],
        token:         token,
        refresh_token: refresh_token,
        project_id:    project_id,
        task_list_id:  task_list_id,
        task_private:  task_private,
        task_description: task_description
      }
    end
  end
end
