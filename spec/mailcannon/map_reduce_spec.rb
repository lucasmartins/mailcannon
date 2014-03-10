require "spec_helper"

describe MailCannon::MapReduce do
  let(:envelope_a) { build(:envelope) }
  let(:envelope_b) { build(:envelope) }
  before(:each) do
    envelope_a.save
    envelope_b.save
    test_hash = [
      {envelope_id: envelope_a.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered'},
      {envelope_id: envelope_a.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open'},
      {envelope_id: envelope_a.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce'},
      {envelope_id: envelope_b.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered'},
      {envelope_id: envelope_b.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  describe "#grab_events_for_envelope" do
    it "inserts the events into the envelope" do
      MailCannon::MapReduce.grab_events_for_envelope(envelope_a.id)
      expect(envelope_a.reload.embedded_sendgrid_events.count).to eq(3)
    end
    
    it "deletes the events from the generic collection to avoid that they are processed more than once" do
      expect do
        MailCannon::MapReduce.grab_events_for_envelope(envelope_a.id)
      end.to change {MailCannon::SendgridEvent.count}.from(5).to(2)
    end
  end
end
