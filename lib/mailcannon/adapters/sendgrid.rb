module MailCannon::Adapter
  module Sendgrid
    include MailCannon::Adapter
    module InstanceMethods
      def send!
        raise 'Invalid Document!' unless self.valid?
        client = SendGridWebApi::Client.new(ENV['SENDGRID_USERNAME'], ENV['SENDGRID_PASSWORD'])
        response = client.mail.send(
          :to => self.to,
          :toname => self.to_name,
          :subject => self.subject,
          :text => self.mail.text,
          :html => self.mail.html,
          :from => self.from,
          :fromname => self.from_name,
          :bcc => self.bcc,
          :replyto => self.reply_to
        )
        if response['message']=='success'
          success = true
        else
          success = false
        end
        self.after_sent(success)
        return response
      end
    end
    
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end