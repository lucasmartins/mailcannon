require "spec_helper"

describe MailCannon::SendgridEvent do

  describe ".insert_bulk" do

    it "inserts events" do
      expect{ MailCannon::SendgridEvent.insert_bulk([{}, {}])}.to change { MailCannon::SendgridEvent.count }.by(2)
    end

    it "returns write result" do
      wresult = MailCannon::SendgridEvent.insert_bulk([{}, {}])
      expect(wresult["ok"]).to be 1.0
      expect(wresult["err"]).to be nil
    end
  end

end
