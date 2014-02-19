require "spec_helper"

describe MailCannon::Adapter::SendgridWeb do
  describe "#auth_pair" do
    let(:envelope) { build(:envelope) }
    let(:envelope_auth_hash) {{'username'=>'envelope-user','password'=>'envelope-passwd'}}
    let(:bag_auth_hash) {{'username'=>'bag-user','password'=>'bag-passwd'}}
    let(:envelope_auth) { build(:envelope, auth: envelope_auth_hash) }
    let(:bag) { build(:empty_envelope_bag, auth: bag_auth_hash) }
    let(:envelope_with_bag_auth) { build(:envelope, envelope_bag: bag) }
    it "uses env vars when no auth values available" do
      expect(envelope.auth_pair).to eq({'username'=>ENV['SENDGRID_USERNAME'],'password'=>ENV['SENDGRID_PASSWORD']})
    end
    it "uses Envelope auth values when available" do
      expect(envelope_auth.auth_pair).to eq(envelope_auth_hash)
    end
    it "uses EnvelopeBag auth values when available" do
      bag.push envelope_with_bag_auth
      bag.save 
      expect(envelope_with_bag_auth.auth_pair).to eq(bag_auth_hash)
    end
  end
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

  context "grab auth exception" do
    describe "#send!" do
    let(:envelope) { build(:envelope_wrong_auth) }
      it "sends http request for Sendgrid web API with a wrong user/passwd combination" do
        Sidekiq::Testing.inline! do
          expect{envelope.send!}.to raise_error(MailCannon::Adapter::AuthException)
        end
      end
    end
  end

end
