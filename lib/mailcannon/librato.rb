module MailCannon::Librato
  extend self
  
  def available?
    if ENV['LIBRATO_USER'] && ENV['LIBRATO_TOKEN']
      true
    else
      false
    end
  end

  def authenticate
    Librato::Metrics.authenticate(ENV['LIBRATO_USER'], ENV['LIBRATO_TOKEN']) if available?
  end
end