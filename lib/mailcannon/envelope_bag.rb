# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::EnvelopeBag
  EVENTS_TO_PROCESS = %w(open delivered spamreport bounce click unsubscribe)

  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::EnvelopeBagMapReduce

  class StatisticsNotReadyError < StandardError ; end

  has_many :envelopes, autosave: true
  field :integration_code, type: String # Used to link your own app models to the Bag.
  field :auth, type: Hash # {user: 'foo', password: 'bar'}, some Adapters might need an token:secret pair, which you can translete into user:password pair. This config will be overriden by the Envelope.auth if present.
  field :pending_stats, type: Boolean, default: false

  def stats
    begin
      MailCannon::EnvelopeBagStatistic.find(self.id).value
    rescue Mongoid::Errors::DocumentNotFound => e
      raise StatisticsNotReadyError, "You haven't run envelope.reduce_statistics yet, no data available!"
    end
  end

  def push(envelope)
    self.envelopes.push envelope
  end
  alias_method :"add",:"push"

  def mark_stats_processed!
    self.pending_stats = false
    self.save!
  end

  # Post this Envelope!
  def post_envelopes!
    return false if envelopes.size==0
    self.save if self.changed?
    envelopes.each do |e|
      unless e.posted?
        e.post!
      end
    end
    true
  end
  alias_method :"post!",:"post_envelopes!"

  def self.mark_for_update!(bags_ids)
    self.where(:_id.in => bags_ids).update_all(pending_stats: true)
  end

  def self.rebuild_stats
    bag_ids = MailCannon::EnvelopeBag.where(pending_stats: true).pluck(:id)
    puts "#{bag_ids.count} bags with pending stats"
    MailCannon::EnvelopeBagReduceJob.perform_async(bag_ids) unless bag_ids.empty?
  end

end
