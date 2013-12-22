module MailCannon::Adapter
  module Sendgrid
    include MailCannon::Adapter
    module InstanceMethods
      def send!
        raise 'Invalid Document!' unless self.valid?
        if self.to.size>1
          response = send_multiple_emails
        else
          response = send_single_email
        end
        self.after_sent(successfully_sent?(response))
        return response
      end
    end
    
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
    
    private
    def api_client
      client = SendGridWebApi::Client.new(ENV['SENDGRID_USERNAME'], ENV['SENDGRID_PASSWORD'])
    end
    
    def send_single_email
      api_client.mail.send(
                :to => self.to.first[:email],
                :toname => self.to.first[:name],
                :subject => self.subject,
                :text => self.mail.text,
                :html => self.mail.html,
                :from => self.from,
                :fromname => self.from_name,
                :bcc => self.bcc,
                :replyto => self.reply_to
              )
    end

    def send_multiple_emails
      api_client.mail.send(
                :to => self.to.first[:email],
                :toname => self.to.first[:name],
                :subject => self.subject,
                :text => self.mail.text,
                :html => self.mail.html,
                :from => self.from,
                :fromname => self.from_name,
                :bcc => self.bcc,
                :replyto => self.reply_to,
                :xsmtpapi => self.xsmtpapi.to_json
              )
    end
    
    def successfully_sent?(response)
      if response['message']=='success'
        true
      else
        false
      end
    end
  end
end