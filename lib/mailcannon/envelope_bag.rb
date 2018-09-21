# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::EnvelopeBag
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :envelopes, autosave: true
  field :integration_code, type: String # Used to link your own app models to the Bag.
  field :auth, type: Hash # {user: 'foo', password: 'bar'}, some Adapters might need an token:secret pair, which you can translete into user:password pair. This config will be overriden by the Envelope.auth if present.
  field :pending_stats, type: Boolean, default: false

  def push(envelope)
    envelopes.push envelope
  end
  alias add push

  def mark_stats_processed!
    self.pending_stats = false
    save!
  end

  def stale?
    created_at && created_at < (ENV["FROZEN_STATISTICS_AFTER_DAYS"] || 15).to_i.days.ago
  end

  # Post this Envelope!
  def post_envelopes!
    return false if envelopes.empty?
    save if changed?
    envelopes.each do |e|
      e.post! unless e.posted?
    end
    true
  end
  alias post! post_envelopes!
end
