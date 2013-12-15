module MailCannon::Adapter

  module InstanceMethods
    def send!
      raise 'Not available for this adapter!'
    end
    def send_bulk!
      raise 'Not available for this adapter!'
    end
  end
  
  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
end