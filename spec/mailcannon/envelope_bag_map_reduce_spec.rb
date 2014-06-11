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

  describe "#js_finalize" do
    it "returns the correct file" do
      js_finalize_file = File.read(MailCannon::EnvelopeBag.js_map_reduce_path("envelope_bag_finalize.js"))
      expect(MailCannon::EnvelopeBag.js_finalize).to eq js_finalize_file
    end
  end

  context "map reduce tests" do

    before(:each) do
      insert_sample_events
    end

    let!(:envelope_bag) { create(:empty_envelope_bag, pending_stats: true) }
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

    describe ".reduce_statistics_for_envelope_bag" do
      let(:expected_hash_a){
        {
          "bounce" => 1.0,
          "click" => 2.0,
          "delivered" => 1.0,
          "open" => 1.0
        }
      }

      let(:expected_hash_b){
        {
          "bounce" => 1.0,
          "click" => 2.0,
          "delivered" => 1.0,
          "open" => 1.0
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
        expect(diff<1.0).to be true
      end

      it "creates an EnvelopeStatistic entry" do
        expect{ MailCannon::EnvelopeBag.reduce_statistics_for_envelope_bag(envelope_bag.id) }.to change{ MailCannon::EnvelopeBagStatistic.count }.from(0).to(1)
      end

      it "returns statistics hash/json" do
        envelope_bag.reduce_statistics
        envelope_bag.reload
        expect(envelope_bag.pending_stats).to be false
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
