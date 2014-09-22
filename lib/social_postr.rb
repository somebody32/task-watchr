require "social_postr/adapters/redbooth"
require "social_postr/adapters/errors"
require "social_postr/token_updaters/redbooth"
require "social_postr/adapters/settings_repository"

module SocialPostr
  module_function

  ADAPTERS_LIST = %w(redbooth)

  # TODO
  # 3. `run poster` should definitely be inside a bg-worker

  def post_task(task)
    ADAPTERS_LIST.each do |adapter_name|
      run_poster(adapter_name, task)
    end
  end

  def run_poster(adapter_name, task)
    full_adapter_name = "Adapters::#{adapter_name.capitalize}"
    adapter_class = const_get(full_adapter_name)
    settings = Adapters::SettingsRepository.fetch(adapter_name)
    adapter = adapter_class.new(settings)
    adapter.post_task(task)
  rescue Adapters::Errors::ExpiredToken
    new_tokens = TokenUpdaters::Redbooth.update_token(settings)
    Adapters::SettingsRepository.save(adapter_name, new_tokens)
    retry
  end
  private_class_method :run_poster
end
