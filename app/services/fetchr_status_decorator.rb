module FetchrStatusDecorator
  module_function

  def fetchr_status
    SocialFetchr.running? ? "Fetcher is running!" : "Fetchr is not running :("
  end

  def twitter_status
    if FetchrSocialSettings.satisfied?
      "Connected as #{FetchrSocialSettings.fetch[:name]}"
    else
      "Not connected"
    end
  end

  def twitter_action_text
    FetchrSocialSettings.satisfied? ? "Update token" : "Connect"
  end

  def redbooth_status
    presenter = Adapters::RedboothSettingsPresenter
    return "Not connected" unless presenter.connected?
    if presenter.fully_satisfied?
      "Connected, configured, yay!"
    else
      "Connected, but additional configuration needed"
    end
  end

  def redbooth_connected?
    Adapters::RedboothSettingsPresenter.connected?
  end

  def redbooth_action_text
    redbooth_connected? ? "Update token" : "Connect"
  end

  def ready_to_start?
    return false if SocialFetchr.running?
    FetchrSocialSettings.satisfied? &&
      Adapters::RedboothSettingsPresenter.fully_satisfied?
  end
end
