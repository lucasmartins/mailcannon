module MailCannon::Airbrake
  extend self
  
  def available?
    if ENV['AIRBRAKE_TOKEN']
      true
    else
      false
    end
  end

  def authenticate
    Airbrake.configure do |config|
      config.api_key = ENV['AIRBRAKE_TOKEN']
      config.host = 'api.airbrake.io'
    end
  end
end