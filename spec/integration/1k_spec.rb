require "spec_helper"

describe "shoot 1k emails!" do
  let(:envelope) { build(:envelope_multi_1k) }
  it "sends http request for Sendgrid web API" do
    VCR.use_cassette('mailcannon_integration_1k') do
      expect(envelope.send_bulk!).to be_true
    end
  end
end
