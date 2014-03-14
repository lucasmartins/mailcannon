class MailCannon::EnvelopeReduceJob
  include Sidekiq::Worker
  
  def perform(envelope_ids)
    envelope_ids.each do |id|
      MailCannon::EnvelopeMapReduce.statistics_for_envelope(id)
    end
  end
  
end