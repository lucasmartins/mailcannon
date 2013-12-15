require 'yaml'

Encoding.default_internal = "utf-8"
Encoding.default_external = "utf-8"

#Adds a way to retrieve Submodules of a Module, used for CustomContentParsers
class Module
  def submodules
    constants.collect {|const_name| const_get(const_name)}.select {|const| const.class == Module}
  end
end

module MailCannon
  
  load 'mailcannon/version.rb'
  
  self.warmode if ENV['MAILCANNON_MODE']=='war'
  
  def self.warmode
    Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV']) # change to env URL
    Librato::Metrics.authenticate(ENV['LIBRATO_USER'], ENV['LIBRATO_TOKEN']) if ENV['LIBRATO_TOKEN'] && ENV['LIBRATO_USER'] # change to initializer
    redis_uri = URI.parse(ENV['REDIS_URL'])
    $redis = Redis.new(host: redis_uri.host, port: redis_uri.port)
  end

  def self.config(root_dir=nil)
    @config ||= load_config(root_dir)
  end

  def self.load_config(root_dir=nil)
    root_dir ||= Pathname.new(Dir.pwd)
    
    path = "#{root_dir}/config/mailcannon.yml"

    raise "Couldn't find config yml at #{path}." unless File.file?(path)
    content = File.read(path)
    erb = ERB.new(content).result
    YAML.load(erb)
  end

end
