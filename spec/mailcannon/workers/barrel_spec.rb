require "spec_helper"

describe MailCannon::Barrel do
  describe "initialize" do
    let(:envelope) { create(:envelope) }
    it "creates a new Stamp" do
      expect{ envelope.post! }.to change{envelope.stamps.size}.by(1)
      expect(envelope.stamps.first.code).to eq(0) # 0=posted
    end
    context "check for expected adapter behavior" do
      it "implements send! behavior" do
        expect(envelope.respond_to?(:send!)).to be_true
      end
    end
  end
end
