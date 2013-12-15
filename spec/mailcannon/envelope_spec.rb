require "spec_helper"

describe MailCannon::Envelope do
  describe "initialize" do
    let(:envelope) { build(:envelope) }
    it "creates a new Stamp" do
      expect{ envelope.save }.to change{MailCannon::Stamp.count}.by(1)
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
  
  describe "#after_sent" do
    let(:envelope) { create(:envelope) }
    it "creates a Processed Stamp" do
      envelope.after_sent(true)
      expect(envelope.stamps.last.event).to be(MailCannon::Event::Processed)
    end
    it "destroys the email content" do
      envelope.after_sent(true)
      expect(envelope.mail).to be_nil
    end
  end
end
