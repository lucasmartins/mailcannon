require 'json-schema'
# Provides the Sendgrid Web API Adapter, refer to http://sendgrid.com/docs/API_Reference/Web_API/mail.html
module MailCannon::Adapter::SendgridWeb
  include MailCannon::Adapter
  module InstanceMethods
    def send!
      begin
        validate_envelope!
        response = send_multiple_emails
        success = successfully_sent?(response)
        raise MailCannon::Adapter::DeliveryFailedException.new(response) unless success

        self.after_sent
      rescue Exception => e
        if e.message == "[\"Permission denied, wrong credentials\"]"
          raise MailCannon::Adapter::AuthException
        else
          raise e
        end
      end
      true
    end

    def send_bulk!
      self.send! # send! does bulk too!
    end

    def auth_pair
      default_auth = {'username'=>ENV['SENDGRID_USERNAME'],'password'=>ENV['SENDGRID_PASSWORD']}
      begin
        self.auth || self.envelope_bag.auth || default_auth  
      rescue Exception => e
        logger.error "Unable to read auth config from Envelope or Bag, using default auth options from ENV"
        return default_auth
      end
    end
  end
  
  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
  
  private
  def api_client
    SendGridWebApi::Client.new(self.auth_pair['username'],self.auth_pair['password'])
  end
  
  def validate_envelope!
    raise "Invalid Document! #{self.errors.messages}" unless self.valid?
  end

  def prepare_xsmtpapi!
    validate_envelope!
    self.xsmtpapi = {} if self.xsmtpapi.nil?
    self.xsmtpapi['sub']={} unless self.xsmtpapi['sub']
    self.xsmtpapi = build_xsmtpapi
    validate_xsmtpapi!
    self.save!
  end

  def build_unique_args
    unique_args = {}
    if MailCannon.config['add_envelope_id_to_unique_args']
      unique_args.merge!({'envelope_id'=>self.id})
    end
    if MailCannon.config['add_envelope_bag_id_to_unique_args'] && self.envelope_bag
      unique_args.merge!({'envelope_bag_id'=>self.envelope_bag.id})
    end
    unique_args
  end

  def build_xsmtpapi
    xsmtpapi = self.xsmtpapi || {}
    xsmtpapi["unique_args"] ||= {}
    xsmtpapi["unique_args"].merge!(build_unique_args)
    xsmtpapi
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

  def send_multiple_emails
    prepare_xsmtpapi!
    api_client.mail.send(
              :to => self.from,
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
    response['message'] == 'success'
  end
end
