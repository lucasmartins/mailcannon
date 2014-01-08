require 'json-schema'
# Provides the Sendgrid Web API Adapter, refer to http://sendgrid.com/docs/API_Reference/Web_API/mail.html
module MailCannon::Adapter::SendgridWeb
  include MailCannon::Adapter
  module InstanceMethods
    def send!
      validate_envelope!
      if self.to.size>1
        response = send_multiple_emails
      else
        response = send_single_email
      end
      self.after_sent(successfully_sent?(response))
      return successfully_sent?(response)
    end

    def send_bulk!
      self.send! # send! does bulk too!
    end
  end
  
  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
  
  private
  def api_client
    client = SendGridWebApi::Client.new(ENV['SENDGRID_USERNAME'], ENV['SENDGRID_PASSWORD'])
  end
  
  def validate_envelope!
    raise "Invalid Document! #{self.errors.messages}" unless self.valid?
  end

  def prepare_xsmtpapi!
    validate_envelope!
    self.xsmtpapi = build_xsmtpapi({'to'=>self.to},{'sub'=>self.substitutions})
    validate_xsmtpapi!
  end

  def build_xsmtpapi(recipients,subs)
    xsmtpapi = {}
    to = []
    recipients['to'].each do |h|
      to.push h[:email]
    end
    xsmtpapi.merge!({'to' => to})
    xsmtpapi.merge!(subs) if subs!=nil && subs.is_a?(Hash)
    return xsmtpapi
  end

  def validate_xsmtpapi!
    return true
    if self.to.size>1
      if xsmtpapi['sub']
        xsmtpapi['sub'].each do |sub|
          raise 'sub[Array] must match to[Array] size!' unless sub.size==xsmtpapi['to'].size
        end
      end
    end
=begin
    schema = {
      "type" => "object",
      "required" => ["to"],
      "properties" => {
        "to" => {"type" => "array", "default" => [self.to.first]}
      }
    }
    JSON::Validator.validate!(schema, self.xsmtpapi)
=end
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
    prepare_xsmtpapi!

    api_client.mail.send(
              :to => self.from,
              #:toname => self.to.first[:name],
              :subject => self.subject,
              :text => self.mail.text,
              :html => self.mail.html,
              :from => self.from,
              :fromname => self.from_name,
              :bcc => self.bcc,
              :replyto => self.reply_to,
              :"x-smtpapi" => self.xsmtpapi.to_json
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
