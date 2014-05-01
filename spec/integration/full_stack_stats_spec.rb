require "spec_helper"

describe 'full stack test' do
  describe "should send 2 envelopes, receive correct statistics and map/reduce data correctly" do

    let(:expected_hash_a){
      {
        "posted"=>{"count"=>1.0, "targets"=>["1"]},
        "processed"=>{"count"=>1.0, "targets"=>["2"]},
        "delivered"=>{"count"=>1.0, "targets"=>["3"]},
        "open" => {"count"=>1.0, "targets"=>["4"]},
        "click"=>{"count"=>1.0, "targets"=>["5"]},
        "deferred"=>{"count"=>1.0, "targets"=>["6"]},
        "spam"=>{"count"=>2.0, "targets"=>["7","8"]},
        "unsubscribe"=>{"count"=>1.0, "targets"=>["9"]},
        "drop"=>{"count"=>1.0, "targets"=>["10"]},
        "bounce" => {"count"=>2.0, "targets"=>["11","12"]},
        "hard_bounce" => {"count"=>1.0, "targets"=>["11"]},
        "soft_bounce"=>{"count"=>1.0, "targets"=>["12"]},
        "unknown"=>{"count"=>1.0, "targets"=>["13"]}
      }
    }

    let(:expected_hash_b){
      {
        "posted"=>{"count"=>2.0, "targets"=>["1", "1" ]},
        "processed"=>{"count"=>2.0, "targets"=>["2", "2"]},
        "delivered"=>{"count"=>2.0, "targets"=>["3", "3"]},
        "open" => {"count"=>2.0, "targets"=>["4", "4"]},
        "click"=>{"count"=>2.0, "targets"=>["5","5"]},
        "deferred"=>{"count"=>2.0, "targets"=>["6", "6"]},
        "spam"=>{"count"=>4.0, "targets"=>["7", "8", "7","8"]},
        "unsubscribe"=>{"count"=>2.0, "targets"=>["9", "9"]},
        "drop"=>{"count"=>2.0, "targets"=>["10", "10"]},
        "bounce" => {"count"=>4.0, "targets"=>["11", "12", "12", "11"]},
        "hard_bounce" => {"count"=>2.0, "targets"=>["11", "11"]},
        "soft_bounce"=>{"count"=>2.0, "targets"=>["12", "12"]},
        "unknown"=>{"count"=>2.0, "targets"=>["13", "13"]}
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
        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          Sidekiq::Testing.inline! do
            bm = Benchmark.measure do
              envelope_a.send_bulk!
            end
          end
        end

        envelope_a_hash = [
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'posted', target_id: '1'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'processed', target_id: '2'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '3'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '4'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'click', type: 'bounce', target_id: '5'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'deferred', type: 'expected', target_id: '6'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'spam_report', target_id: '7'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'spam', target_id: '8'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'unsubscribe', target_id: '9'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'drop', target_id: '10'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'bounce', target_id: '11'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'expected', target_id: '12'},
          {envelope_id: envelope_a.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'gfyigad', target_id: '13'},
        ]
        MailCannon::SendgridEvent.insert_bulk(envelope_a_hash)

        Sidekiq::Testing.inline! do
          MailCannon::EnvelopeBagReduceJob.perform_async([envelope_bag.id])
        end

        expect(envelope_a.reload.sendgrid_events.where(processed: true).count).to eq(13)
        expect(envelope_bag.stats).to eq(expected_hash_a)

        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          Sidekiq::Testing.inline! do
            bm = Benchmark.measure do
              envelope_b.send_bulk!
            end
          end
        end

        envelope_b_hash = [
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'posted', target_id: '1'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'processed', target_id: '2'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'delivered', target_id: '3'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'open', target_id: '4'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'click', type: 'bounce', target_id: '5'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'deferred', type: 'expected', target_id: '6'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'spam_report', target_id: '7'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'spam', target_id: '8'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo1@bar.com', timestamp: 1322000092, unique_arg: 'my unique arg', event: 'unsubscribe', target_id: '9'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo2@bar.com', timestamp: 1322000093, unique_arg: 'my unique arg', event: 'drop', target_id: '10'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'bounce', target_id: '11'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'bounce', type: 'expected', target_id: '12'},
          {envelope_id: envelope_b.id, envelope_bag_id: envelope_bag.id, email: 'foo3@bar.com', timestamp: 1322000094, unique_arg: 'my unique arg', event: 'gfyigad', target_id: '13'},
        ]
        MailCannon::SendgridEvent.insert_bulk(envelope_b_hash)

        Sidekiq::Testing.inline! do
          MailCannon::EnvelopeBagReduceJob.perform_async([envelope_bag.id])
        end

        expect(envelope_b.reload.sendgrid_events.where(processed: true).count).to eq(13)
        expect(envelope_bag.stats).to eq(expected_hash_b)
      end
    end

  end
end
