class MailCannon::AggregationJob
  include Sidekiq::Worker
  
  def perform(envelope_ids)
    envelope_ids.each do |id|
      MailCannon::MapReduce.grab_events_for_envelope(id)
    end
  end
  
end