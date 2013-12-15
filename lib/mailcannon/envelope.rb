load 'app/models/mailgun/adapters/sendgrid.rb'

class Mailgun::Envelope
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mailgun::Adapter::Sendgrid
  
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
  
  validates :from, :to, :subject, :mail, presence: true
  validates_associated :mail
  
  after_create do |envelope|
    envelope.stamp! Mailgun::Event::New.stamp
    MailCannon::SingleBarrel.perform_async(envelope.id)
  end
  
  def stamp!(code)
    unless [Integer, Mailgun::Stamp].include?(code.class) || Mailgun::Event.constants.include?(code)
      raise 'code must be an Integer, Mailgun::Event::*, or Mailgun::Stamp !'
    end
    if code.is_a? Integer
      self.stamps << Mailgun::Stamp.new({code: code})
    elsif code.is_a? Mailgun::Stamp
      self.stamps << code
    else # Mailgun::Event::*
      self.stamps << code.stamp
    end
  end
  
  def after_sent(response)
    if response
      stamp!(Mailgun::Event::Processed.stamp)
      self.mail.destroy
    end
  end
    
end

# Mailgun::Envelope.new({from: 'test@rdstation.com.br', to: 'lucasmartins@me.com', subject: 'Test'})

# Mailgun::Envelope.new({from: 'test@rdstation.com.br', to: 'lucasmartins@me.com', subject: 'Test', mail: Mailgun::Mail.new({text: "If you can't read the HTML content, you're screwed!", html: "<html><body><p>You should see what happens when your email client can't read HTML content.</p></body></html>"})})