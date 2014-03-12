class MailCannon::AggregationJob
  include Sidekiq::Worker
  
  def perform(envelope_ids)
    envelope_ids.each do |id|
      MailCannon::MapReduce.statistics_for_envelope(id)
    end
  end
  
end