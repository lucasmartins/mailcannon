load 'lib/mailcannon/adapters/sendgrid.rb'

class MailCannon::Envelope
  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::Adapter::Sendgrid
  
  has_one :mail
  has_many :stamps
  
  field :from, type: String
  field :from_name, type: String
  field :to, type: String
  field :to_name, type: String
  field :subject, type: String
  field :bcc, type: String
  field :reply_to, type: String
  field :date, type: Date
  field :xsmtpapi, type: Hash
  
  validates :from, :to, :subject, :mail, presence: true
  validates_associated :mail
  
  after_create do |envelope|
    envelope.stamp! MailCannon::Event::New.stamp
    MailCannon::SingleBarrel.perform_async(envelope.id)
  end
  
  def stamp!(code)
    unless [Fixnum, MailCannon::Stamp].include?(code.class) || MailCannon::Event.constants.include?(code.to_s.camelize.to_sym)
      raise 'code must be an Integer, MailCannon::Event::*, or MailCannon::Stamp !'
    end
    if code.is_a? Fixnum
      self.stamps << MailCannon::Stamp.new({code: code})
    elsif code.is_a? MailCannon::Stamp
      self.stamps << code
    else # MailCannon::Event::*
      self.stamps << code.stamp
    end
  end
  
  def after_sent(response)
    if response
      stamp!(MailCannon::Event::Processed.stamp)
      self.mail.destroy
      self.mail=nil # to avoid reload
    end
  end
    
end

# MailCannon::Envelope.new({from: 'test@rdstation.com.br', to: 'lucasmartins@me.com', subject: 'Test'})

# MailCannon::Envelope.new({from: 'test@rdstation.com.br', to: 'lucasmartins@me.com', subject: 'Test', mail: MailCannon::Mail.new({text: "If you can't read the HTML content, you're screwed!", html: "<html><body><p>You should see what happens when your email client can't read HTML content.</p></body></html>"})})