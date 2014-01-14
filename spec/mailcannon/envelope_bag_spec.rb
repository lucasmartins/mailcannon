require "spec_helper"

describe MailCannon::EnvelopeBag do
  describe "#post!" do
    context "when it has no Envelopes" do
      let(:envelope_bag) { build(:empty_envelope_bag) }
      it "does not raise error" do
        expect{envelope_bag.post!}.not_to raise_error
      end
      it "returns false" do
        expect(envelope_bag.post!).to be_false
      end
    end
    context "when it has Envelopes" do
      let(:envelope_bag) { build(:filled_envelope_bag) }
      it "does not raise error" do
        expect{envelope_bag.post!}.not_to raise_error
      end
      it "returns true" do
        expect(envelope_bag.post!).to be_true
      end
      it "posts Envelopes in the bag" do
        envelopes = envelope_bag.envelopes.to_a
        expect(envelopes.size).to eq(2)
        # Rspec can't do 'any_instance.should_receive' twice.
        envelopes.first.should_receive(:post!)
        envelopes.last.should_receive(:post!)
        envelope_bag.post!
      end
    end
  end
end
