require "spec_helper"

describe MailCannon::EnvelopeMapReduce do
  let(:envelope_a) { build(:envelope) }
  let(:envelope_b) { build(:envelope) }
  let(:envelope_c) { build(:envelope) }

  def insert_sample_events
    test_hash = [
      {envelope_id: envelope_a.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_a.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '2'},
      {envelope_id: envelope_a.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', target_id: '3'},
      {envelope_id: envelope_b.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
      {envelope_id: envelope_b.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click', target_id: '2'},
      {envelope_id: envelope_c.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'click', target_id: '1'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  before(:each) do
    envelope_a.save
    envelope_b.save
    envelope_c.save
    insert_sample_events
  end

  describe "#change_events_status_for_envelope" do
    it "sets events status (processed) to :lock(false)" do
      MailCannon::Envelope.change_events_status_for_envelope(envelope_a.id, nil, :lock)
      expect(envelope_a.reload.sendgrid_events.where(processed: false).count).to eq(3)
    end
    
    it "sets events status (processed) to :processed(true)" do
      MailCannon::Envelope.change_events_status_for_envelope(envelope_a.id, nil, :processed)
      expect(envelope_a.reload.sendgrid_events.where(processed: true).count).to eq(3)
    end
  end

  describe ".reduce_statistics_for_envelope" do
    let(:expected_hash_a){ {"posted"=>{"count"=>0.0, "targets"=>[]},
        "processed"=>{"count"=>0.0, "targets"=>[]},
        "delivered"=>{"count"=>1.0, "targets"=>["1"]},
        "open"=>{"count"=>1.0, "targets"=>["2"]},
        "click"=>{"count"=>0.0, "targets"=>[]},
        "deferred"=>{"count"=>0.0, "targets"=>[]},
        "spam_report"=>{"count"=>0.0, "targets"=>[]},
        "spam"=>{"count"=>0.0, "targets"=>[]},
        "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
        "drop"=>{"count"=>0.0, "targets"=>[]},
        "bounce"=>{"count"=>1.0, "targets"=>["3"]}} }

    let(:expected_hash_b){ {"posted"=>{"count"=>0.0, "targets"=>[]},
        "processed"=>{"count"=>0.0, "targets"=>[]},
        "delivered"=>{"count"=>2.0, "targets"=>["1","1"]},
        "open"=>{"count"=>2.0, "targets"=>["2","2"]},
        "click"=>{"count"=>0.0, "targets"=>[]},
        "deferred"=>{"count"=>0.0, "targets"=>[]},
        "spam_report"=>{"count"=>0.0, "targets"=>[]},
        "spam"=>{"count"=>0.0, "targets"=>[]},
        "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
        "drop"=>{"count"=>0.0, "targets"=>[]},
        "bounce"=>{"count"=>2.0, "targets"=>["3","3"]}} }

    it "measure reduce output availability" do
      envelope_a.reduce_statistics
      start_time = Time.now
      while MailCannon::EnvelopeStatistic.count==0
        sleep 1
      end
      end_time = Time.now
      diff = end_time-start_time
      expect(diff<1.0).to be_true
    end

    it "creates an EnvelopeStatistic entry" do
      expect{ MailCannon::Envelope.reduce_statistics_for_envelope(envelope_a.id) }.to change{ MailCannon::EnvelopeStatistic.count }.from(0).to(1)
    end

    it "returns statistics hash/json" do
      envelope_a.reduce_statistics
      expect(envelope_a.stats).to eq(expected_hash_a)
    end

    it "merges recurring reduces" do
      envelope_a.reduce_statistics
      expect(envelope_a.stats).to eq(expected_hash_a)
      insert_sample_events
      envelope_a.reduce_statistics
      expect(envelope_a.stats).to eq(expected_hash_b)
    end
  end

end
