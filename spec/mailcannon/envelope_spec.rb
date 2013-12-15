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
  end
end
=begin

unless [Integer, MailCannon::Stamp].include?(code.class) || MailCannon::Event.constants.include?(code)
  raise 'code must be an Integer, MailCannon::Event::*, or MailCannon::Stamp !'
end
if code.is_a? Integer
  self.stamps << MailCannon::Stamp.new({code: code})
elsif code.is_a? MailCannon::Stamp
  self.stamps << code
else # MailCannon::Event::*
  self.stamps << code.stamp
end

EVENTS = [
  'new',
  'processed',
  'delivered',
  'open',
  'click',
  'deferred',
  'spam_report',
  'spam',
  'unsubscribe',
  'drop',
  'bounce'
]

EVENTS.each do |module_name|
=end