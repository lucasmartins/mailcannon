require "spec_helper"

describe MailCannon::Barrel do
  describe "perform", sidekiq: :inline do
    let(:envelope) { create(:envelope) }
    it "creates a new Stamp" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        expect{ envelope.post! }.to change{envelope.stamps.size}.by(1)
      end
      expect(envelope.stamps.first.code).to eq(0) # 0=posted
    end
    it "looks for an existing MongoDB document" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        expect{envelope.post!}.not_to raise_error
      end
    end
    it "runs the job without errors" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        expect{envelope.post!}.not_to raise_error
      end
    end
    context "check for expected adapter behavior" do
      it "implements send! behavior" do
        expect(envelope.respond_to?(:send!)).to be true
      end
    end
  end
end
