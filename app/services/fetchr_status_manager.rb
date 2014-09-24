module FetchrStatusManager
  module_function

  def ready_to_start?
    return false if SocialFetchr.running?
    FetchrSocialSettings.satisfied?
  end
end
