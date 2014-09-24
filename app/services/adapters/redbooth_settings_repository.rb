module Adapters
  module RedboothSettingsRepository
    module_function

    def update(params)
      params = decrypt_task_list_id(params)
      updated_settings = RedboothSettings.fetch.attributes.merge(params)
      RedboothSettings.new(updated_settings).save
    end

    def update_tokens(tokens)
      updated_settings = RedboothSettings.fetch.attributes.merge(tokens)
      RedboothSettings.new(updated_settings).save
    end

    def decrypt_task_list_id(params)
      task_list_id, project_id = params[:task_list_id].split("/")
      params.merge(
        task_list_id: task_list_id,
        project_id: project_id
      )
    end
  end
end
