require "spec_helper"

describe MailCannon::EnvelopeStatistic do
  
  let(:envelope_a) { build(:envelope) }
  let(:envelope_b) { build(:envelope) }

  def insert_sample_events
    test_hash = [
      {envelope_id: envelope_a.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_a.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '2'},
      {envelope_id: envelope_a.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', target_id: '3'},
      {envelope_id: envelope_b.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_b.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click', target_id: '2'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  before(:each) do
    envelope_a.save
    envelope_b.save
    insert_sample_events
  end
  
  describe "stats" do
    it "has expected keys" do
      envelope_a.reduce_statistics
      expect(envelope_a.stats).to have_key("posted")
      expect(envelope_a.stats).to have_key("processed")
      expect(envelope_a.stats).to have_key("delivered")
      expect(envelope_a.stats).to have_key("open")
      expect(envelope_a.stats).to have_key("click")
      expect(envelope_a.stats).to have_key("deferred")
      expect(envelope_a.stats).to have_key("spam_report")
      expect(envelope_a.stats).to have_key("spam")
      expect(envelope_a.stats).to have_key("unsubscribe")
      expect(envelope_a.stats).to have_key("drop")
      expect(envelope_a.stats).to have_key("bounce")
    end
  end
end
