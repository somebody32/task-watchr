ruby '2.1.2'
source 'https://rubygems.org'

gem 'rails', '4.1.6'
gem 'twitter', '~> 5.11'
gem 'redis', '~> 3.1.0'
gem 'sidekiq', '~> 3.2'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'omniauth-redbooth', '~> 0.0'
gem 'omniauth-twitter', '~> 1.0'

gem 'twitter-bootstrap-rails', '~> 3.2'
gem 'jquery-rails'
gem 'uglifier'

gem 'rails_12factor'

group :development, :test do
  gem 'dotenv-rails', '~> 0.11'
  gem 'rspec-rails', '~> 3.1.0'
end

group :development do
  gem 'guard-rspec', '~> 4.3', require: false
  gem 'rubocop', '~> 0.26', require: false
end

group :test do
  gem 'vcr', '~> 2.9.3'
  gem 'webmock', '~> 1.18'
  gem 'database_cleaner', '~> 1.3'
  gem 'timecop', '~> 0.7'
end
