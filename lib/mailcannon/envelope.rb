# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::Envelope
  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::Adapter::SendgridWeb
  
  embeds_one :mail
  embeds_many :stamps
  
  field :group_id, type: Bignum # create sparse Index for this field, put this in RDoc
  field :from, type: String
  field :from_name, type: String
  field :to, type: Array # of hashes. [{email: '', name: ''},...]
  field :substitutions, type: Hash # of hashes
  field :subject, type: String
  field :bcc, type: String
  field :reply_to, type: String
  field :date, type: Date
  field :xsmtpapi, type: Hash # this will mostly be used by MailCannon itself. http://sendgrid.com/docs/API_Reference/SMTP_API/index.html
  
  validates :from, :to, :subject, :mail, presence: true
  validates_associated :mail

  # Post this Envelope!
  def post_envelope!
    self.save if self.changed?
    self.stamp! MailCannon::Event::Posted.stamp
    if validate_xsmtpapi(self.xsmtpapi)
      MailCannon::Barrel.perform_in(MailCannon.config['waiting_time'].seconds,self.id)
    else
      raise 'Invalid xsmtpapi hash!'
    end
  end
  alias_method :"post!",:"post_envelope!"

  # Stamp this Envelope with code.
  def stamp!(code,recipient=nil)
    self.class.valid_code_kind?(code)
    unless self.persisted?
      puts "You're trying to save the Stamp with an unsaved Envelope! Auto-saving Stamp."
      self.save
    end
    self.stamps.create(code: MailCannon::Stamp.from_code(code).code, recipient: recipient)
  end
  
  # Callback to be run after the Envelope has been processed.
  def after_sent(response)
    if response
      stamp!(MailCannon::Event::Processed.stamp)
      self.mail.destroy
      self.mail=nil # to avoid reload
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