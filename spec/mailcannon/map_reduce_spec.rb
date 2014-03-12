require "spec_helper"

describe MailCannon::MapReduce do
  let(:envelope_a) { build(:envelope) }
  let(:envelope_b) { build(:envelope) }
  let(:envelope_c) { build(:envelope) }
  before(:each) do
    envelope_a.save
    envelope_b.save
    envelope_c.save
    test_hash = [
      {envelope_id: envelope_a.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered'},
      {envelope_id: envelope_a.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open'},
      {envelope_id: envelope_a.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce'},
      {envelope_id: envelope_b.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered'},
      {envelope_id: envelope_b.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click'},
      {envelope_id: envelope_c.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  describe "#grab_events_for_envelope" do
    it "inserts the events into the envelope" do
      MailCannon::MapReduce.grab_events_for_envelope(envelope_a.id)
      expect(envelope_a.reload.sendgrid_events.count).to eq(3)
    end
    
  it "deals with only one event" do
      expect do
        MailCannon::MapReduce.grab_events_for_envelope(envelope_c.id)
      end.to change {envelope_c.sendgrid_events.first.processed}.to be_false
    end

    it "changes processed status to false (lock)" do
      expect do
        MailCannon::MapReduce.grab_events_for_envelope(envelope_a.id)
      end.to change {envelope_a.sendgrid_events.pluck(:processed)}.to match_array([false,false,false])
    end
  end

end
