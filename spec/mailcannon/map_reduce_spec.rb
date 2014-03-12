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
      {envelope_id: envelope_a.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', lead_id: '1'},
      {envelope_id: envelope_a.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', lead_id: '2'},
      {envelope_id: envelope_a.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', lead_id: '3'},
      {envelope_id: envelope_b.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', lead_id: '1'},
      {envelope_id: envelope_b.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click', lead_id: '2'},
      {envelope_id: envelope_c.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'click', lead_id: '1'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  describe ".grab_events_for_envelope" do
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

  describe ".statistics_for_envelope" do
    it "returns statistics hash/json" do
      mapreduce = MailCannon::MapReduce.statistics_for_envelope(envelope_a.id)
      expected_hash = {       
        "posted"=>{"count"=>0.0, "leads"=>[]},
        "processed"=>{"count"=>0.0, "leads"=>[]},
        "delivered"=>{"count"=>1.0, "leads"=>["1"]},
        "open"=>{"count"=>1.0, "leads"=>["2"]},
        "click"=>{"count"=>0.0, "leads"=>[]},
        "deferred"=>{"count"=>0.0, "leads"=>[]},
        "spam_report"=>{"count"=>0.0, "leads"=>[]},
        "spam"=>{"count"=>0.0, "leads"=>[]},
        "unsubscribe"=>{"count"=>0.0, "leads"=>[]},
        "drop"=>{"count"=>0.0, "leads"=>[]},
        "bounce"=>{"count"=>1.0, "leads"=>["3"]}}
      expect(mapreduce.raw['results'].first['value']).to eq(expected_hash)
    end
  end

end
