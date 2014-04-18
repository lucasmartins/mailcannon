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

  def build_to_subs(placeholder, to_key)
    selected_hash_array = []
    self.to.map {|h| selected_hash_array.push h[to_key]||h[to_key.to_sym]||''}
    {'sub'=>{"#{placeholder}"=>selected_hash_array}}
  end

  def build_name_subs
    placeholder = MailCannon.config['default_name_placeholder'] || '%name%'
    build_to_subs(placeholder, 'name')
  end

  def build_email_subs
    placeholder = MailCannon.config['default_email_placeholder'] || '%email%'
    build_to_subs(placeholder, 'email')
  end


  def build_unique_args
    unique_args = {}
    if MailCannon.config['add_envelope_id_to_unique_args']
      unique_args.merge!({'envelope_id'=>self.id})
    end
    unique_args
  end

  def build_xsmtpapi(recipients,subs)
    xsmtpapi = self.xsmtpapi || {}
    recipients.symbolize_keys!
    to = extract_values(recipients[:to],:email)
    xsmtpapi.merge!({'to' => to}) if to
    xsmtpapi = merge_subs_hash(xsmtpapi,subs)
    xsmtpapi = merge_subs_hash(xsmtpapi,build_name_subs)
    xsmtpapi = merge_subs_hash(xsmtpapi,build_email_subs)
    xsmtpapi.merge!({'unique_args' => build_unique_args })
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

  def merge_subs_hash(xsmtpapi,subs)
    if subs!=nil && subs.is_a?(Hash)
      xsmtpapi.deep_merge(subs)
    else
      xsmtpapi
    end
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
