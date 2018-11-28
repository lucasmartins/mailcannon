# Provides the Sendgrid Web API Adapter, refer to http://sendgrid.com/docs/API_Reference/Web_API/mail.html
module MailCannon::Adapter::SendgridWeb
  include MailCannon::Adapter
  module InstanceMethods
    def send!
      begin
        validate_envelope!
        response = send_multiple_emails
        success = successfully_sent?(response)
        raise MailCannon::Adapter::DeliveryFailedException, response unless success

        after_sent
      rescue Exception => e
        if e.message.include?("Permission denied, wrong credentials")
          raise MailCannon::Adapter::AuthException
        else
          raise e
        end
      end
      true
    end

    def send_bulk!
      send! # send! does bulk too!
    end

    def auth_pair
      default_auth = { "username" => ENV["SENDGRID_USERNAME"], "password" => ENV["SENDGRID_PASSWORD"] }
      begin
        auth || envelope_bag.auth || default_auth
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
    SendGridWebApi::Client.new(auth_pair["username"], auth_pair["password"])
  end

  def validate_envelope!
    raise "Invalid Document! #{errors.messages}" unless valid?
  end

  def prepare_xsmtpapi!
    validate_envelope!
    self.xsmtpapi = {} if xsmtpapi.nil?
    xsmtpapi["sub"] = {} unless xsmtpapi["sub"]
    self.xsmtpapi = build_xsmtpapi
    save!
  end

  def build_unique_args
    unique_args = {}
    unique_args["envelope_id"] = id if MailCannon.config["add_envelope_id_to_unique_args"]
    if MailCannon.config["add_envelope_bag_id_to_unique_args"] && envelope_bag
      unique_args["envelope_bag_id"] = envelope_bag.id
    end
    unique_args
  end

  def build_xsmtpapi
    xsmtpapi = self.xsmtpapi || {}
    xsmtpapi["to"] = to.map { |d| d["email"] }
    xsmtpapi["unique_args"] ||= {}
    xsmtpapi["unique_args"].merge!(build_unique_args)
    xsmtpapi
  end

  def send_multiple_emails
    prepare_xsmtpapi!
    api_client.mail.send(
      :to          => from,
      :subject     => subject,
      :text        => mail.text,
      :html        => mail.html,
      :from        => from,
      :fromname    => from_name,
      :bcc         => bcc,
      :replyto     => reply_to,
      :"x-smtpapi" => xsmtpapi.to_json,
      :headers     => headers.to_json
    )
  end

  def successfully_sent?(response)
    response["message"] == "success"
  end
end
