redis_conn = proc {
  Redis.new(url: ENV["REDIS_URL"]) # do anything you want here
}
Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 1, &redis_conn)
end
Sidekiq.configure_server do |config|
  config.redis = ConnectionPool.new(size: 2, &redis_conn)
end
