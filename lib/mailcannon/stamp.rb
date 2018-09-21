# Holds information about a recipient's email event, like deliveries and bounces.
class MailCannon::Stamp
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :envelope

  field :code, type: Integer, default: 0
  field :recipient # email address for this "notification"
  validates :code, presence: true

  # Returns the Event for this Stamp.
  def event
    MailCannon::Event.from_code(code)
  end

  # Creates a Stamp from an Event code.
  # @param code Can be either an Integer, a MailCannon::Event or the MailCannon::Stamp itself.
  def self.from_code(code)
    if code.is_a? Integer
      MailCannon::Stamp.new(code: code)
    elsif code.is_a? MailCannon::Stamp
      code
    else # MailCannon::Event::*
      code.stamp
    end
  end
end
