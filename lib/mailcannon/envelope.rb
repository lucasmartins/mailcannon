# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::Envelope
  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::Adapter::SendgridWeb

  belongs_to :envelope_bag, index: true

  embeds_one :mail
  embeds_many :stamps
  has_many :sendgrid_events

  field :from, type: String
  field :from_name, type: String
  field :to, type: Array # of hashes. [{email: '', name: ''},...]
  field :subject, type: String
  field :bcc, type: String
  field :reply_to, type: String
  field :date, type: Date
  field :xsmtpapi, type: Hash # this will mostly be used by MailCannon itself. http://sendgrid.com/docs/API_Reference/SMTP_API/index.html
  field :auth, type: Hash # {user: 'foo', password: 'bar'}, some Adapters might need an token:secret pair, which you can translete into user:password pair.
  field :jid, type: String
  field :headers, type: Hash

  validates :from, :to, :subject, presence: true
  validates_associated :mail

  # Post this Envelope!
  def post_envelope!(options = {})
    save if changed?
    raise "Envelope(#{id}) has no mail! Didn't you already send it?" unless mail

    schedule_send_job(options[:queue])
    save if changed?
  end
  alias post! post_envelope!

  # Stamp this Envelope with code.
  def stamp!(code, recipient = nil)
    self.class.valid_code_kind?(code)
    unless persisted?
      logger.warn "You're trying to save the Stamp with an unsaved Envelope! Auto-saving Envelope."
      save
    end
    stamps.create(code: MailCannon::Stamp.from_code(code).code, recipient: recipient)
  end

  # Callback to be run after the Envelope has been processed.
  def after_sent
    stamp!(MailCannon::Event::Processed.stamp)
    if MailCannon.config["auto_destroy"]
      mail.destroy
      self.mail = nil # to avoid reload
    end
  end

  def posted?
    stamps.where(code: 0).count > 0
  end

  def processed?
    stamps.where(code: 1).count > 0
  end

  private

  def schedule_send_job(queue)
    queue ||= :mail_delivery

    self.jid = if MailCannon.config["waiting_time"].to_i > 0
                 Sidekiq::Client.enqueue_to_in(queue, MailCannon.config["waiting_time"].seconds, MailCannon::Barrel, id)
               else
                 Sidekiq::Client.enqueue_to(queue, MailCannon::Barrel, id)
               end
    if jid
      stamp! MailCannon::Event::Posted.stamp
      return jid
    end
  end

  def self.valid_code_kind?(code)
    unless [Integer, MailCannon::Stamp].include?(code.class) || MailCannon::Event.constants.include?(code.to_s.camelize.to_sym)
      raise "code must be an Integer, MailCannon::Event::*, or MailCannon::Stamp !"
    end
  end
end
