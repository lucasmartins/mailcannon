require "spec_helper"

describe MailCannon::MapReduce do
  let(:envelope_a) { build(:envelope) }
  let(:envelope_b) { build(:envelope) }
  before(:each) do
    envelope_a.save
    envelope_b.save
    test_hash = [
      {envelope_id: envelope_a.id ,email: 'foo1@bar.com', timestamp: 1322000095, unique_arg: 'my unique arg', event: 'delivered'},
      {envelope_id: envelope_a.id ,email: 'foo1@bar.com', timestamp: 1322000095, unique_arg: 'my unique arg', event: 'open'},
      {envelope_id: envelope_b.id ,email: 'foo2@bar.com', timestamp: 1322000095, unique_arg: 'my unique arg', event: 'delivered'},
      {envelope_id: envelope_b.id ,email: 'foo2@bar.com', timestamp: 1322000095, unique_arg: 'my unique arg', event: 'click'}
    ]
    MailCannon::SendgridEvent.insert_bulk(test_hash)
  end

  describe "#grab_events" do
    it "does shit" do
      
    end
  end
end
