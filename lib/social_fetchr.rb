require "social_fetchr/workers/updater"
require "social_fetchr/workers/importer"

module SocialFetchr
  module_function

  def check_updates(credentials:, async: false)
    if async
      Workers::Updater.perform_async(credentials)
    else
      Workers::Updater.perform_inline(credentials)
    end
  end

  def process_all(credentials:, async: false)
    if async
      Workers::Importer.perform_async(credentials)
    else
      Workers::Importer.perform_inline(credentials)
    end
  end
end
