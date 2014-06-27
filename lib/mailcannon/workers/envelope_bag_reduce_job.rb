class MailCannon::EnvelopeBagReduceJob
  include Sidekiq::Worker

  sidekiq_options :queue => :event_processing

  def perform(bag_id)
    bag_id = bag_id['$oid'] if bag_id.respond_to?(:[]) && bag_id['$oid']
    puts "reducing stats for bag #{bag_id}"
    MailCannon::EnvelopeBag.reduce_statistics_for_envelope_bag(bag_id)
  end

end
