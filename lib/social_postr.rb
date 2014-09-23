require "social_postr/postr_worker"

module SocialPostr
  module_function

  ADAPTERS_LIST = %w(redbooth)

  def post_task(task)
    ADAPTERS_LIST.each do |adapter_name|
      run_poster(adapter_name, task)
    end
  end

  def run_poster(adapter_name, task)
    PostrWorker.perform_async(adapter_name, task)
  end
  private_class_method :run_poster
end
