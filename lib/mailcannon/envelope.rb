# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::Envelope
  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::Adapter::SendgridWeb
  
  embeds_one :mail
  embeds_many :stamps
  belongs_to :envelope_bag

  field :from, type: String
  field :from_name, type: String
  field :to, type: Array # of hashes. [{email: '', name: ''},...]
  field :substitutions, type: Hash # of hashes
  field :subject, type: String
  field :bcc, type: String
  field :reply_to, type: String
  field :date, type: Date
  field :xsmtpapi, type: Hash # this will mostly be used by MailCannon itself. http://sendgrid.com/docs/API_Reference/SMTP_API/index.html
  field :jid, type: String

  
  validates :from, :to, :subject, presence: true
  validates_associated :mail

  # Post this Envelope!
  def post_envelope!
    self.save if self.changed?
    raise 'Envelope has no mail!' unless self.mail
    if validate_xsmtpapi(self.xsmtpapi)
      if MailCannon.config['waiting_time'] && MailCannon.config['waiting_time'].to_i>0
        self.jid = MailCannon::Barrel.perform_in(MailCannon.config['waiting_time'].seconds,self.id)
      else
        self.jid = MailCannon::Barrel.perform_async(self.id)
      end
      if self.jid
        self.stamp! MailCannon::Event::Posted.stamp
        return self.jid
      end
    else
      raise 'Invalid xsmtpapi hash!'
    end
  end
  alias_method :"post!",:"post_envelope!"

  # Stamp this Envelope with code.
  def stamp!(code,recipient=nil)
    self.class.valid_code_kind?(code)
    unless self.persisted?
      logger.warn "You're trying to save the Stamp with an unsaved Envelope! Auto-saving Envelope."
      self.save
    end
    self.stamps.create(code: MailCannon::Stamp.from_code(code).code, recipient: recipient)
  end
  
  # Callback to be run after the Envelope has been processed.
  def after_sent(response)
    if response
      stamp!(MailCannon::Event::Processed.stamp)
      if MailCannon.config['auto_destroy']
        self.mail.destroy
        self.mail=nil # to avoid reload
      end
    end
  end

  def posted?
    if self.stamps.where(code: 0).count > 0
      true
    else
      false
    end
  end
  
  private
  def self.valid_code_kind?(code)
    unless [Fixnum, MailCannon::Stamp].include?(code.class) || MailCannon::Event.constants.include?(code.to_s.camelize.to_sym)
      raise 'code must be an Integer, MailCannon::Event::*, or MailCannon::Stamp !'
    end
  end

  def validate_xsmtpapi(xsmtpapi)
    return true # TODO write tests for this method
    if xsmtpapi['to'].is_a? Array
      true
    else
      false
    end
  end
    
end