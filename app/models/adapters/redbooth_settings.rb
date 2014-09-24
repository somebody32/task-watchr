module Adapters
  class RedboothSettings
    include ActiveModel::Model

    attr_accessor :project_id, :task_list_id, :task_private,
                  :task_description, :token, :refresh_token
    validates :project_id, :task_list_id,
              presence: true,
              numericality: { only_integer: true }

    def self.fetch
      SocialPostr::Adapters::SettingsRepository.fetch(:redbooth)
    end

    def save
      SocialPostr::Adapters::SettingsRepository.save(:redbooth, attributes)
    end

    private

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
