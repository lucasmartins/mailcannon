class MailCannon::EnvelopeReduceJob
  include Sidekiq::Worker
  
  def perform(envelope_ids)
    envelope_ids.each do |id|
      id = id['$oid'] if id['$oid']
      MailCannon::EnvelopeMapReduce.statistics_for_envelope(id)
    end
  end
  
end