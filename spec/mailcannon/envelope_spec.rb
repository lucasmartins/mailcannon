require "spec_helper"

describe MailCannon::Envelope do
  describe "initialization" do
    let(:envelope) { build(:envelope) }
    it "has no Stamps" do
      envelope.save
      expect(envelope.stamps.size).to eq(0)
    end
    context "check for expected adapter behavior" do
      it "implements send! behavior" do
        expect(envelope.respond_to?(:send!)).to be true
      end
    end
  end
  
  describe "#stamp!" do
    context "passing Integer" do
      let(:envelope) { build(:envelope) }
      it "creates a Stamp" do
        expect{ envelope.stamp!(2) }.to change{ envelope.stamps.size }.by(1)
      end
      it "creates the right kind of Stamp" do
        envelope.stamp!(2)
        expect(envelope.stamps.last).to be_kind_of(MailCannon::Stamp)
        expect(envelope.stamps.last.event.to_i).to be(2)
      end
    end
    context "passing Stamp" do
      let(:envelope) { build(:envelope) }
      let(:stamp) { build(:stamp, code: 3) }
      it "creates a Stamp" do
        expect{ envelope.stamp!(stamp) }.to change{ envelope.stamps.size }.by(1)
      end
      it "creates the right kind of Stamp" do
        envelope.stamp!(stamp)
        expect(envelope.stamps.last).to be_kind_of(MailCannon::Stamp)
        expect(envelope.stamps.last.event.to_i).to be(3)
      end
    end
    context "passing Event" do
      let(:envelope) { build(:envelope) }
      let(:event) { MailCannon::Event::Click }
      
      it "creates a Stamp" do
        expect{ envelope.stamp!(event) }.to change{ envelope.stamps.size }.by(1)
      end
      it "creates the right kind of Stamp" do
        envelope.stamp!(event)
        expect(envelope.stamps.last).to be_kind_of(MailCannon::Stamp)
        expect(envelope.stamps.last.event.to_i).to be(4)
      end
    end
  end
  
  describe "#posted?" do
    context "when already posted" do
      let(:envelope) { build(:envelope) }
      it "returns true" do
        VCR.use_cassette('mailcannon_adapter_sendgrid_send') do
          envelope.post!
        end
        expect(envelope.posted?).to be true
      end
    end
    context "when not yet posted" do
      let(:envelope) { build(:envelope) }
      it "returns false" do
        expect(envelope.posted?).to be false
      end
    end
  end

  describe "#schedule to any queue" do
    let(:envelope) { build(:envelope_multi, xsmtpapi: { "unique_args" => { "userid" => "1123", "template" => "welcome" }}) }

    it "allows posting to any queue" do
      envelope.post!(queue: :foo_queue)
      expect(MailCannon::Barrel.jobs.first["queue"]).to eq("foo_queue")
    end

    it "enqueues to mail_delivery by default" do
      envelope.post!
      expect(MailCannon::Barrel.jobs.first["queue"]).to eq("mail_delivery")
    end
  end

  describe "xsmtpapi", sidekiq: :inline do
    context "keep xsmtpapi arguments after #post!" do
      let(:envelope_bag) { build(:empty_envelope_bag)}
      let(:envelope) { build(:envelope_multi, xsmtpapi: { "unique_args" => { "userid" => "1123", "template" => "welcome" }}) }
      let(:name_placeholder) { MailCannon.config['default_name_placeholder'].to_s }

      it "returns true" do
        envelope_bag.save
        envelope_bag.envelopes << envelope
        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          envelope.post!
        end
        envelope.reload # content is changed inside the Adapter module
        expect(envelope.xsmtpapi).to have_key("unique_args")
        expect(envelope.xsmtpapi["unique_args"]).to have_key("envelope_id") if MailCannon.config['add_envelope_id_to_unique_args']
        expect(envelope.xsmtpapi["unique_args"]).to have_key("envelope_bag_id") if MailCannon.config['add_envelope_bag_id_to_unique_args']
        expect(envelope.xsmtpapi).to have_key("to")
        expect(envelope.xsmtpapi).to have_key("sub")
        expect(envelope.xsmtpapi['sub']).to have_key("*|NAME|*")
        expect(envelope.xsmtpapi['sub'][name_placeholder]).to match_array(['Mail Cannon','Lucas Martins','Contact'])
      end
    end
  end

  describe "#after_sent" do
    let(:envelope) { create(:envelope) }
    it "creates a Processed Stamp" do
      envelope.after_sent
      expect(envelope.stamps.last.event).to be(MailCannon::Event::Processed)
    end
    it "destroys the email content" do
      envelope.after_sent
      expect(envelope.mail).to be_nil
    end
  end
end
