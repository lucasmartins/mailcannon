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
      expect(envelope_bag.stats).to have_key("posted")
      expect(envelope_bag.stats).to have_key("processed")
      expect(envelope_bag.stats).to have_key("delivered")
      expect(envelope_bag.stats).to have_key("open")
      expect(envelope_bag.stats).to have_key("click")
      expect(envelope_bag.stats).to have_key("deferred")
      expect(envelope_bag.stats).to have_key("spam_report")
      expect(envelope_bag.stats).to have_key("spam")
      expect(envelope_bag.stats).to have_key("unsubscribe")
      expect(envelope_bag.stats).to have_key("drop")
      expect(envelope_bag.stats).to have_key("soft_bounce")
      expect(envelope_bag.stats).to have_key("hard_bounce")
      expect(envelope_bag.stats).to have_key("unknown")
    end
  end
end
