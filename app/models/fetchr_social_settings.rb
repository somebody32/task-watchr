class FetchrSocialSettings
  include ActiveModel::Model
  DB_KEY = :social_fetchr_settings
  FETCHR_KEYS = [:app_key, :app_secret, :client_key, :client_secret]
  attr_accessor :client_key, :client_secret, :name
  validates :client_key, :client_secret, presence: true

  def self.fetch
    db_client.hgetall(DB_KEY).symbolize_keys
  end

  def self.satisfied?
    fetch.values_at(*FETCHR_KEYS).all?
  end

  def save
    return false unless valid?
    self.class.db_client.mapped_hmset(DB_KEY, attributes)
    true
  end

  def self.for_fetchr
    fetch.slice(*FETCHR_KEYS)
  end

  private

  def attributes
    {
      app_key: ENV["TWITTER_KEY"],
      app_secret: ENV["TWITTER_SECRET"],
      client_key: client_key,
      client_secret: client_secret,
      name: name
    }
  end

  def self.db_client
    Redis.new(url: ENV["REDIS_URL"])
  end
end
