source 'https://rubygems.org'

gem 'redis'
gem 'mongoid'
gem 'sidekiq'
gem 'sendgrid_webapi'
#gem 'sendgrid_toolkit'
gem 'librato-metrics'
gem 'rubysl', platform: :rbx
gem 'jruby-openssl', platform: :jruby
#for SendgridWeb adapter
gem "yajl-ruby", :platforms=>[:rbx,:ruby]
gem "json-schema"

group :development do
  gem 'rake'
  gem 'pry'
  gem 'pry-nav'
  gem 'yard'
end

group :test do
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec-expectations'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'vcr'
  gem 'webmock', '>= 1.8.0', '< 1.16'
  gem 'coveralls', require: false
end