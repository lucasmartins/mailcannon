# Where the magic happens, the Envelope is responsible for keeping the information necessary to send the email(s) and holding the Stamps related to mailing Events.
class MailCannon::EnvelopeBag
  include Mongoid::Document
  include Mongoid::Timestamps
  
  has_many :envelopes, autosave: true

  # Post this Envelope!
  def post_envelopes!
    return false if self.envelopes.size==0
    self.save if self.changed?
    self.envelopes.each do |e|
      e.post! unless e.posted?
    end
  end
  alias_method :"post!",:"post_envelopes!"
    
end