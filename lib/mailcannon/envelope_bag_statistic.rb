# Holds information about a recipient's email event, like deliveries and bounces.
class MailCannon::EnvelopeBagStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
end
