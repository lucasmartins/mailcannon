class MailCannon::EnvelopeReduceJob
  include Sidekiq::Worker
  
  def perform(envelope_bag_ids)
    envelope_bag_ids.each do |id|
      id = id['$oid'] if id['$oid']
      MailCannon::EnvelopeBagMapReduce.statistics_for_envelope(id)
    end
  end
  
end