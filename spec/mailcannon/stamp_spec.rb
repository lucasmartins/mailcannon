require "spec_helper"

describe MailCannon::Stamp do
  describe "#event" do
    let(:stamp) { build(:stamp, code: 7) }
    it "returns an Event" do
      expect(stamp.event).to be(MailCannon::Event::Spam)
    end
  end
  describe "#from_code" do
    it "returns a Stamp with appropriate code" do
      expect do
        MailCannon::Event::EVENTS.each_with_index do |_e, i|
          raise "Not a Stamp!" unless MailCannon::Stamp.from_code(i).is_a?(MailCannon::Stamp)
        end
      end.not_to raise_error
    end
  end
end
