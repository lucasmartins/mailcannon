require "spec_helper"

describe MailCannon::Adapter::SendgridWeb do
  describe "#send!" do
    let(:envelope) { build(:envelope) }
    it "sends http request for Sendgrid web API" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        expect(envelope.send!).to be_true
      end
    end
    it "calls after_sent callback" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
        envelope.should_receive(:after_sent)
        envelope.send!
      end
    end
  end

  describe "#send_bulk!" do
    let(:envelope) { build(:envelope_multi) }
    it "sends http request for Sendgrid web API" do
      VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
        expect(envelope.send_bulk!).to be_true
      end
    end
  end
end
