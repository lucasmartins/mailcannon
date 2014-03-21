require 'yaml'
require 'openssl'
require 'bundler'
require 'json'
require 'mongoid'
require 'sidekiq'
require 'sendgrid_webapi'
require 'yajl-ruby' if RUBY_PLATFORM=='ruby'
require 'jruby-openssl' if RUBY_PLATFORM=='jruby'
require 'librato/metrics'
require 'airbrake'

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

module MailCannon
  require_relative 'mailcannon/adapter'
  require_relative 'mailcannon/adapters/sendgrid_web'
  require_relative 'mailcannon/envelope_bag'
  require_relative 'mailcannon/envelope_statistic'
  require_relative 'mailcannon/envelope_map_reduce'
  require_relative 'mailcannon/envelope'  
  require_relative 'mailcannon/mail'
  require_relative 'mailcannon/stamp'
  require_relative 'mailcannon/event'
  require_relative 'mailcannon/sendgrid_event'
  require_relative 'mailcannon/workers/barrel'
  require_relative 'mailcannon/workers/envelope_reduce_job'
  require_relative 'mailcannon/airbrake'
  require_relative 'mailcannon/version'
  
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

  # alias method
  def logger
    MailCannon.logger
  end

  # Returns the lib logger object
  def self.logger
    @logger || initialize_logger
  end

  # Initializes logger with mailcannon setup
  def self.initialize_logger(log_target = STDOUT)
    oldlogger = @logger
    @logger = Logger.new(log_target)
    @logger.level = Logger::INFO
    @logger.progname = 'mailcannon'
    oldlogger.close if oldlogger && !$TESTING # don't want to close testing's STDOUT logging
    @logger
  end

end
