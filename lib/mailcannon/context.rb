module MailCannon
  module Context

    module InstanceMethods
      def setup_highrise
        Highrise::Base.site = self.highrise_base_url
        Highrise::Base.user = self.highrise_token
        Highrise::Base.format = :xml  
      end
    end

    def self.included(receiver)
      receiver.send :include, InstanceMethods
      check_expected_behavior(receiver)
    end

    private
    def self.check_expected_behavior(receiver)
      unless receiver.method_defined? 'highrise_base_url'
        raise 'Your model must respond to "highrise_base_url"'
      end
      unless receiver.method_defined? 'highrise_token'
        raise 'Your model must respond to "highrise_token"'
      end
    end
  end

end