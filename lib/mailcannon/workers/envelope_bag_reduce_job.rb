class MailCannon::EnvelopeBagReduceJob
  include Sidekiq::Worker
  
  def perform(envelope_bag_ids)
    envelope_bag_ids.each do |id|
      id = id['$oid'] if id['$oid']
      MailCannon::EnvelopeBag.reduce_statistics_for_envelope_bag(id)
    end
  end
  
end