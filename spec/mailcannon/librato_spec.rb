require "spec_helper"

describe MailCannon::Librato do
  after(:each) do
    ENV['LIBRATO_USER']=nil
    ENV['LIBRATO_TOKEN']=nil
  end
  describe "#available?" do
    context 'when Librato info is NOT in the ENV' do
      it "returns false" do
        ENV['LIBRATO_USER']=nil
        ENV['LIBRATO_TOKEN']=''
        expect(MailCannon::Librato.available?).to be_false
      end
    end
    context 'when Librato info IS in the ENV' do
      it "returns false" do
        ENV['LIBRATO_USER']='tha.user'
        ENV['LIBRATO_TOKEN']='tha.password'
        expect(MailCannon::Librato.available?).to be_true
      end
    end
  end
end
