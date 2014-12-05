require "spec_helper"

describe MailCannon::EnvelopeBagStatistic do

  let!(:envelope_bag) { build(:empty_envelope_bag) }
  let!(:envelope_a) { build(:envelope, envelope_bag_id: envelope_bag.id) }

  def insert_sample_events
    test_hash = [
      {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '2'},
      {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', target_id: '3'},
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  before(:each) do
    envelope_bag.save
    envelope_a.save
    insert_sample_events
  end

  describe "stats" do
    it "has expected keys" do
      envelope_bag.reduce_statistics
      envelope_bag.reload
      expect(envelope_bag.pending_stats).to be false
      expect(envelope_bag.stats.keys).to include *%w(delivered open bounce)
    end
  end
end
