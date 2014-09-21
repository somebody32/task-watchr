require "social_postr/adapters/redbooth"
require "social_postr/adapters/errors"

module SocialPostr
  module_function

  ADAPTERS_LIST = %w(redbooth)

  # TODO
  # 1. need to understand how to get adapter settings
  # 2. need to understand how token updaters will work
  # 3. `run poster` should definitely be inside a bg-worker

  def post_task(task)
    ADAPTERS_LIST.each do |adapter_name|
      full_adapter_name = "Adapters::#{adapter_name.capitalize}"
      adapter = const_get(full_adapter_name)
      run_poster(adapter.new("some settings"), task)
    end
  end

  def run_poster(adapter, task)
    adapter.post_task(task)
  rescue Adapters::Errors::ExpiredToken
    TokenUpdater::Redbooth.update_token
    retry
  end
end