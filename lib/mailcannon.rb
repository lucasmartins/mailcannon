require 'yaml'
require 'openssl'
require 'bundler'
require 'json'
#should use Bundler
require 'mongoid'
require 'sidekiq'
require 'sendgrid_webapi'
require 'yajl-ruby' if RUBY_PLATFORM=='ruby'
require 'jruby-openssl' if RUBY_PLATFORM=='jruby'
#require 'librato-metrics'

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

module MailCannon
  require_relative 'mailcannon/adapter'
  require_relative 'mailcannon/adapters/sendgrid_web'
  require_relative 'mailcannon/envelope'
  require_relative 'mailcannon/mail'
  require_relative 'mailcannon/stamp'
  require_relative 'mailcannon/event'
  require_relative 'mailcannon/workers/barrel'
  require_relative 'mailcannon/version'
  
  #Librato::Metrics.authenticate(ENV['LIBRATO_USER'], ENV['LIBRATO_TOKEN']) if ENV['LIBRATO_TOKEN'] && ENV['LIBRATO_USER'] # change to initializer
  # If your client is single-threaded, we just need a single connection in our Redis connection pool
  
  # To be used with caution
  def self.warmode
    #Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV']||'development') # change to env URL
    Sidekiq.configure_client do |config|
      config.redis = { :namespace => 'mailcannon', :size => 1, :url => ENV['REDIS_URL'] }
    end
  end
  self.warmode if ENV['MAILCANNON_MODE']=='war'

  # Returns the config Hash
  def self.config(root_dir=nil)
    @config ||= load_config(root_dir)
  end

  # Loads the config Hash from the YAML
  def self.load_config(root_dir=nil)
    root_dir ||= Pathname.new(Dir.pwd)
    
    path = "#{root_dir}/config/mailcannon.yml"

    raise "Couldn't find config yml at #{path}." unless File.file?(path)
    content = File.read(path)
    erb = ERB.new(content).result
    YAML.load(erb)
  end

end
