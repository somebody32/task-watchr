require "social_postr/adapters/redbooth"
require "social_postr/adapters/errors"
require "social_postr/token_updaters/redbooth"

module SocialPostr
  module_function

  ADAPTERS_LIST = %w(redbooth)

  # TODO
  # 1. need to understand how to get adapter settings
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
    TokenUpdaters::Redbooth.update_token
    retry
  end
end
