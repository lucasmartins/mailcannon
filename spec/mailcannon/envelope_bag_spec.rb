require "spec_helper"

describe MailCannon::EnvelopeBag do
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
        MailCannon::EnvelopeBag.mark_for_update!([envelope_bag._id])
        envelope_bag.reload

        expect(envelope_bag.pending_stats).to be true
      end
    end

    context "When rebuilding stats" do
      it "posts only bags that are eligible for rebuilding of stats" do
        eligible_bag = create(:empty_envelope_bag, pending_stats: true)
        not_eligible_bag = create(:empty_envelope_bag, pending_stats: false)

        expect(MailCannon::EnvelopeBagReduceJob).to receive(:perform_async).with([eligible_bag._id])
        MailCannon::EnvelopeBag.rebuild_stats
      end
    end
  end
end
