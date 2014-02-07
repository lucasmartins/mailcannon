module MailCannon::Barrel::Librato
  extend self
  
  def available?
    if ENV['LIBRATO_USER'] && ENV['LIBRATO_PASSWORD']
      true
    else
      false
    end
  end

  def authenticate
    Librato::Metrics.authenticate(ENV['LIBRATO_USER'], ENV['LIBRATO_PASSWORD']) if available?
  end
end