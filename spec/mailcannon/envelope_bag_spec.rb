require "spec_helper"

describe MailCannon::EnvelopeBag do
  describe "#stale?" do
    let(:envelope_bag) { build(:empty_envelope_bag) }

    it "returns false when it's a recent bag" do
      envelope_bag.created_at = Date.today
      expect(envelope_bag).to_not be_stale
    end

    it "returns true when it's too old" do
      envelope_bag.created_at = 3.months.ago
      expect(envelope_bag).to be_stale
    end

    it "checks if bag is stale from env variable" do
      ENV['FROZEN_STATISTICS_AFTER_DAYS'] = '20'
      envelope_bag.created_at = 19.days.ago
      expect(envelope_bag).to_not be_stale

      envelope_bag.created_at = 21.days.ago
      expect(envelope_bag).to be_stale

      ENV['FROZEN_STATISTICS_AFTER_DAYS'] = nil
    end
  end

  describe "#post!" do

    context "when it has no Envelopes" do
      let(:envelope_bag) { build(:empty_envelope_bag) }

      it "does not raise error" do
        expect{envelope_bag.post!}.not_to raise_error
      end
      it "returns false" do
        expect(envelope_bag.post!).to be false
      end
    end

    context "when it has Envelopes" do
      let(:envelope_bag) { build(:filled_envelope_bag) }

      it "does not raise error" do
        expect{envelope_bag.post!}.not_to raise_error
      end
      it "returns true" do
        expect(envelope_bag.post!).to be true
      end
    end

    context "when it has Envelopes (isolating Bag)" do
      let(:envelope_bag) { MailCannon::EnvelopeBag.new }

      it "posts Envelopes in the bag" do
        envelope_bag.envelopes.push build(:envelope)
        envelope_bag.envelopes.push build(:envelope_multi)
        expect(envelope_bag.envelopes.size).to eq(2)
        # Rspec can't do 'any_instance.should_receive' twice.
        envelope_bag.envelopes.each do |envelope|
          expect(envelope).to receive(:post!)
        end
        envelope_bag.post!
      end
    end

    context "When marking bags for map reduce update" do
      let(:envelope_bag) { create(:empty_envelope_bag) }

      it "marks bag available for map reduce" do
        MailCannon::EnvelopeBag.mark_for_update!([envelope_bag.id])
        envelope_bag.reload

        expect(envelope_bag.pending_stats).to be true
      end
    end

    context "When rebuilding stats" do
      it "posts bags that are eligible for rebuilding of stats" do
        eligible_bag1 = create(:empty_envelope_bag, pending_stats: true)
        eligible_bag2 = create(:empty_envelope_bag, pending_stats: true)
        not_eligible_bag = create(:empty_envelope_bag, pending_stats: false)

        expect(MailCannon::EnvelopeBagReduceJob).to receive(:perform_async).with(eligible_bag1.id)
        expect(MailCannon::EnvelopeBagReduceJob).to receive(:perform_async).with(eligible_bag2.id)
        expect(MailCannon::EnvelopeBagReduceJob).to_not receive(:perform_async).with(not_eligible_bag.id)
        MailCannon::EnvelopeBag.rebuild_stats
      end
    end
  end
end
