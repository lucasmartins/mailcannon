require "spec_helper"

describe MailCannon::EnvelopeBagMapReduce do

  describe "#js_map" do

    it "returns the correct file" do
      js_map_file = File.read(MailCannon::EnvelopeBag.js_map_reduce_path("envelope_bag_map.js"))
      expect(MailCannon::EnvelopeBag.js_map).to eq js_map_file
    end

  end

  describe "#js_reduce" do
    it "returns the correct file" do
      js_reduce_file = File.read(MailCannon::EnvelopeBag.js_map_reduce_path("envelope_bag_reduce.js"))
      expect(MailCannon::EnvelopeBag.js_reduce).to eq js_reduce_file
    end
  end

  context "map reduce tests" do

    before(:each) do
      insert_sample_events
    end

    let!(:envelope_bag) { create(:empty_envelope_bag) }
    let(:envelope_a) { create(:envelope, envelope_bag_id: envelope_bag.id) }
    let(:envelope_b) { create(:envelope, envelope_bag_id: envelope_bag.id) }
    let(:envelope_c) { create(:envelope, envelope_bag_id: envelope_bag.id) }

    def insert_sample_events
      test_hash = [
        {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
        {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '2'},
        {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'bounce', target_id: '3'},
        {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '1'},
        {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'click', target_id: '2'},
        {envelope_id: envelope_c.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'click', target_id: '1'}
      ]
      MailCannon::SendgridEvent.insert_bulk(test_hash)
    end

    describe "#change_events_status_for_envelope" do
      it "sets events status (processed) to :lock(false)" do
        MailCannon::EnvelopeBag.change_events_status_for_envelope_bag(envelope_bag.id, nil, :lock)
        expect(envelope_a.reload.sendgrid_events.where(processed: false).count).to eq(3)
        expect(envelope_b.reload.sendgrid_events.where(processed: false).count).to eq(2)
        expect(envelope_c.reload.sendgrid_events.where(processed: false).count).to eq(1)
      end

      it "sets events status (processed) to :processed(true)" do
        MailCannon::EnvelopeBag.change_events_status_for_envelope_bag(envelope_bag.id, nil, :processed)
        expect(envelope_a.reload.sendgrid_events.where(processed: true).count).to eq(3)
        expect(envelope_b.reload.sendgrid_events.where(processed: true).count).to eq(2)
        expect(envelope_c.reload.sendgrid_events.where(processed: true).count).to eq(1)
      end
    end

    describe ".reduce_statistics_for_envelope_bag" do
      let(:expected_hash_a){
        {
          "posted"=>{"count"=>0.0, "targets"=>[]},
          "processed"=>{"count"=>0.0, "targets"=>[]},
          "delivered"=>{"count"=>2.0, "targets"=>["1", "1"]},
          "open"=>{"count"=>1.0, "targets"=>["2"]},
          "click"=>{"count"=>2.0, "targets"=>["2", "1"]},
          "deferred"=>{"count"=>0.0, "targets"=>[]},
          "spam"=>{"count"=>0.0, "targets"=>[]},
          "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
          "drop"=>{"count"=>0.0, "targets"=>[]},
          "bounce"=>{"count"=>1.0, "targets"=>["3"]},
          "hard_bounce"=>{"count"=>1.0, "targets"=>["3"]},
          "soft_bounce"=>{"count"=>0.0, "targets"=>[]},
          "unknown"=>{"count"=>0.0, "targets"=>[]}
        }
      }

      let(:expected_hash_b){
        {
          "posted"=>{"count"=>0.0, "targets"=>[]},
          "processed"=>{"count"=>0.0, "targets"=>[]},
          "delivered"=>{"count"=>4.0, "targets"=>["1", "1","1", "1"]},
          "open"=>{"count"=>2.0, "targets"=>["2", "2"]},
          "click"=>{"count"=>4.0, "targets"=>["2", "1","2", "1"]},
          "deferred"=>{"count"=>0.0, "targets"=>[]},
          "spam"=>{"count"=>0.0, "targets"=>[]},
          "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
          "drop"=>{"count"=>0.0, "targets"=>[]},
          "bounce"=>{"count"=>2.0, "targets"=>["3","3"]},
          "hard_bounce"=>{"count"=>2.0, "targets"=>["3","3"]},
          "soft_bounce"=>{"count"=>0.0, "targets"=>[]},
          "unknown"=>{"count"=>0.0, "targets"=>[]}
        }
      }

      it "measure reduce output availability" do
        envelope_bag.reduce_statistics
        start_time = Time.now
        while MailCannon::EnvelopeBagStatistic.count==0
          sleep 1
        end
        end_time = Time.now
        diff = end_time-start_time
        expect(diff<1.0).to be_true
      end

      it "creates an EnvelopeStatistic entry" do
        expect{ MailCannon::EnvelopeBag.reduce_statistics_for_envelope_bag(envelope_bag.id) }.to change{ MailCannon::EnvelopeBagStatistic.count }.from(0).to(1)
      end

      it "returns statistics hash/json" do
        envelope_bag.reduce_statistics
        expect(envelope_bag.stats).to eq(expected_hash_a)
      end

      it "merges recurring reduces" do
        envelope_bag.reduce_statistics
        expect(envelope_bag.stats).to eq(expected_hash_a)
        insert_sample_events
        envelope_bag.reduce_statistics
        expect(envelope_bag.stats).to eq(expected_hash_b)
      end
    end
  end

end
