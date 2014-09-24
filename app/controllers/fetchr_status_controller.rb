class FetchrStatusController < ApplicationController
  def show
    @manager = FetchrStatusManager
  end

  def start
    SocialFetchr.check_and_process_updates(
      credentials: FetchrSocialSettings.for_fetchr,
      async: true
    )
    redirect_to :root
  end

  def import_and_start
    SocialFetchr.process_all(
      credentials: FetchrSocialSettings.for_fetchr,
      async: true
    )
    redirect_to :root
  end
end
