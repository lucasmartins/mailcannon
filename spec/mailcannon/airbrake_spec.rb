require "spec_helper"

describe MailCannon::Airbrake do
  before(:each) do
    ENV['AIRBRAKE_TOKEN']=nil
  end
  after(:each) do
    ENV['AIRBRAKE_TOKEN']=nil
  end
  describe "#available?" do
    context 'when Airbrake token is NOT in the ENV' do
      it "returns false" do
        expect(MailCannon::Airbrake.available?).to be_false
      end
    end
    context 'when Airbrake token IS in the ENV' do
      it "returns false" do
        ENV['AIRBRAKE_TOKEN']='a.token'
        expect(MailCannon::Airbrake.available?).to be_true
      end
    end
  end
end
