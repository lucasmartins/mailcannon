# Holds information about a recipient's email event, like deliveries and bounces.
class MailCannon::EnvelopeStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
  #include Mongoid::DynamicFields
  index("_id"=> 1)
end
