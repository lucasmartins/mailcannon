require 'yaml'
require 'openssl'
require 'bundler'
require 'json'
require 'mongoid'

case ENV['RACK_ENV']
when 'production'
  Bundler.require(:default)
else
  Bundler.require(:default,:development)
end

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

module MailCannon
  require_relative 'mailcannon/adapter'
  require_relative 'mailcannon/adapters/sendgrid_web'
  require_relative 'mailcannon/envelope'
  require_relative 'mailcannon/mail'
  require_relative 'mailcannon/stamp'
  require_relative 'mailcannon/event'
  require_relative 'mailcannon/workers/single_barrel'
  require_relative 'mailcannon/version'
  
  self.warmode if ENV['MAILCANNON_MODE']=='war'
  
  # To be used with caution
  def self.warmode
    Bundler.require(:default)
    Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV']) # change to env URL
    Librato::Metrics.authenticate(ENV['LIBRATO_USER'], ENV['LIBRATO_TOKEN']) if ENV['LIBRATO_TOKEN'] && ENV['LIBRATO_USER'] # change to initializer
    redis_uri = URI.parse(ENV['REDIS_URL'])
    $redis = Redis.new(host: redis_uri.host, port: redis_uri.port)
  end

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
