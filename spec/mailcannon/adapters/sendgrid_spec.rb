require "spec_helper"

describe MailCannon::Adapter::Sendgrid do
  describe "#send!" do
    let(:envelope) { build(:envelope) }
    it "sends http request for Sendgrid web API" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        expect(envelope.send!).to eq({"message"=>"success"})
      end
    end
    it "calls after_sent callback" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        envelope.should_receive(:after_sent)
        envelope.send!
      end
    end
  end
end

