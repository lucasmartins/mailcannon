class MailCannon::Envelope
  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::Adapter::Sendgrid
  
  embeds_one :mail
  embeds_many :stamps
  
  field :from, type: String
  field :from_name, type: String
  field :to, type: Array # strings
  field :to_name, type: Array # strings
  field :substitutions, type: Array # hashes
  field :subject, type: String
  field :bcc, type: String
  field :reply_to, type: String
  field :date, type: Date
  field :xsmtpapi, type: Hash # this will mostly be used by MailCannon itself.
  
  validates :from, :to, :subject, :mail, presence: true
  validates_associated :mail
  
  after_create :post_envelope!

  def post_envelope!
    self.save if self.changed?
    self.stamp! MailCannon::Event::New.stamp
    if validate_xsmtpapi(self.xsmtpapi)
      MailCannon::SingleBarrel.perform_async(self.id)
    else
      raise 'Invalid xsmtpapi hash!'
    end
  end

  def stamp!(code)
    self.class.valid_code_kind?(code)
    self.stamps << MailCannon::Stamp.from_code(code)
  end
  
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
