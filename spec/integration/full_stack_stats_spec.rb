require "spec_helper"

describe 'full stack test', sidekiq: :inline do
  describe "should send 2 envelopes, receive correct statistics and map/reduce data correctly" do

    let(:expected_hash_a){
      {
        "bounce" => 2.0,
        "click" => 1.0,
        "delivered" => 1.0,
        "open" => 1.0,
        "spamreport" => 1.0,
        "unsubscribe" => 1.0
      }
    }

    let(:expected_hash_b){
      {
        "bounce" => 2.0,
        "click" => 1.0,
        "delivered" => 1.0,
        "open" => 1.0,
        "spamreport" => 1.0,
        "unsubscribe" => 1.0
      }
    }

    context "send emails and map reduce" do
      let(:envelope_bag) { build(:empty_envelope_bag)}
      let!(:envelope_a) { build(:envelope_multi) }
      let!(:envelope_b) { build(:envelope_multi) }

      it "sends http request for Sendgrid web API" do
        envelope_bag.save
        envelope_bag.envelopes << envelope_a
        envelope_bag.envelopes << envelope_b

        MailCannon::EnvelopeBag.mark_for_update!([envelope_bag.id])
        envelope_bag.reload
        expect(envelope_a.envelope_bag.pending_stats).to be true

        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          bm = Benchmark.measure do
            envelope_a.send_bulk!
          end
        end

        envelope_a_hash = [
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'posted', target_id: '1'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'processed', target_id: '2'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '3'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '4'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'click', type: 'bounce', target_id: '5'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'deferred', type: 'expected', target_id: '6'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'spamreport', target_id: '8'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'unsubscribe', target_id: '9'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'drop', target_id: '10'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'bounce', target_id: '11'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'expected', target_id: '12'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'gfyigad', target_id: '13'},
        ]
        MailCannon::SendgridEvent.insert_bulk(envelope_a_hash)

        MailCannon::EnvelopeBagReduceJob.perform_async(envelope_bag.id)

        envelope_bag.reload
        expect(envelope_bag.pending_stats).to be false
        expect(envelope_bag.stats).to eq(expected_hash_a)

        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          bm = Benchmark.measure do
            envelope_b.send_bulk!
          end
        end

        envelope_b_hash = [
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'posted', target_id: '1'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'processed', target_id: '2'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '3'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '4'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'click', type: 'bounce', target_id: '5'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'deferred', type: 'expected', target_id: '6'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'spamreport', target_id: '8'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'unsubscribe', target_id: '9'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'drop', target_id: '10'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'bounce', target_id: '11'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'expected', target_id: '12'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'gfyigad', target_id: '13'},
        ]
        MailCannon::SendgridEvent.insert_bulk(envelope_b_hash)

        MailCannon::EnvelopeBagReduceJob.perform_async(envelope_bag.id)

        expect(envelope_a.reload.envelope_bag.pending_stats).to be false
        expect(envelope_bag.stats).to eq(expected_hash_b)
      end
    end

  end
end
