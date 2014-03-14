require 'json-schema'
# Provides the Sendgrid Web API Adapter, refer to http://sendgrid.com/docs/API_Reference/Web_API/mail.html
module MailCannon::Adapter::SendgridWeb
  include MailCannon::Adapter
  module InstanceMethods
    def send!
      begin
        validate_envelope!
        response = send_multiple_emails
        self.after_sent(successfully_sent?(response))
        return successfully_sent?(response)
      rescue Exception => e
        if e.message == "[\"Permission denied, wrong credentials\"]"
          raise MailCannon::Adapter::AuthException
        else
          raise e
        end
      end
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
    self.xsmtpapi = self.xsmtpapi.deep_merge(build_xsmtpapi({'to'=>self.to},{'sub'=>self.substitutions}))
    validate_xsmtpapi!
    self.save!
  end

  def build_name_subs
    name_placeholder = MailCannon.config['default_name_placeholder'] || '%name%'
    selected_hash_array = []
    self.to.map {|h| selected_hash_array.push h['name']||h[:name]||''}
    {'sub'=>{"#{name_placeholder}"=>selected_hash_array}}
  end

  def build_email_subs
    email_placeholder = MailCannon.config['default_email_placeholder'] || '%email%'
    selected_hash_array = []
    self.to.map {|h| selected_hash_array.push h['email']||h[:email]||''}
    {'sub'=>{"#{email_placeholder}"=>selected_hash_array}}
  end

  def build_xsmtpapi(recipients,subs)
    xsmtpapi = self.xsmtpapi || {}
    recipients.symbolize_keys!
    to = extract_values(recipients[:to],:email)
    xsmtpapi.merge!({'to' => to}) if to
    xsmtpapi = xsmtpapi.deep_merge(subs) if subs!=nil && subs['sub']!=nil
    xsmtpapi = xsmtpapi.deep_merge(build_name_subs) if build_name_subs!=nil && build_name_subs.is_a?(Hash)
    xsmtpapi = xsmtpapi.deep_merge(build_email_subs) if build_email_subs!=nil && build_email_subs.is_a?(Hash)
    return xsmtpapi
  end

  def extract_values(values,key)
    extract=[]
    values.each do |h|
      h.symbolize_keys!
      extract.push h[key]
    end
    extract
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
    if response['message']=='success'
      true
    else
      false
    end
  end
end
