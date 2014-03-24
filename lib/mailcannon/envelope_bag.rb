# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::EnvelopeBag
  include Mongoid::Document
  include Mongoid::Timestamps
  include MailCannon::EnvelopeBagMapReduce
  
  has_many :envelopes, autosave: true
  field :integration_code, type: String # Used to link your own app models to the Bag.
  field :auth, type: Hash # {user: 'foo', password: 'bar'}, some Adapters might need an token:secret pair, which you can translete into user:password pair. This config will be overriden by the Envelope.auth if present.

  def stats
    begin
      MailCannon::EnvelopeBagStatistic.find(self.id).value  
    rescue Mongoid::Errors::DocumentNotFound => e
      raise "You haven't run envelope.reduce_statistics yet, no data available!"
    end
  end

  def push(envelope)
    self.envelopes.push envelope
  end
  alias_method :"add",:"push"

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
    
end