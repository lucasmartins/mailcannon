require "spec_helper"

describe MailCannon::EnvelopeReduceJob do
  describe "perform" do

    let(:bag_1) { create(:filled_envelope_bag) }
    let(:bag_2) { create(:filled_envelope_bag) }

    it "calls the reduce trigger for each envelope" do
      Sidekiq::Testing.inline! do
        MailCannon::EnvelopeBagMapReduce.should_receive(:statistics_for_envelope).with(bag_2.id.to_s).and_return(nil)
        MailCannon::EnvelopeBagMapReduce.should_receive(:statistics_for_envelope).with(bag_1.id.to_s).and_return(nil)
        MailCannon::EnvelopeReduceJob.perform_async([bag_2.id, bag_1.id])
      end
    end
  end
end
