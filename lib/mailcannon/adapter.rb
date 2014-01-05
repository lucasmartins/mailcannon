# Provides an Interface for implementing an Adapter. Adapters are supposed to handle communication with the email service (ie: Sendgrid) and to be included by MailCannon::Envelope. MailCannon::Envelope attributes should be accessed to figure out what to send to the email service.
module MailCannon::Adapter
  module InstanceMethods
    # Sends an Envelope with 1 recipient.
    def send!
      raise 'Not available for this adapter!'
    end
    
    # Sends an Envelope with multiple recipients.
    def send_bulk!
      raise 'Not available for this adapter!'
    end
  end
  
  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
end