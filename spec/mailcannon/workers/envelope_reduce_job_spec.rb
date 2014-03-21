require "spec_helper"

describe MailCannon::EnvelopeReduceJob do
  describe "perform" do
    let(:envelope_a) { create(:envelope) }
    let(:envelope_b) { create(:envelope_multi) }
    it "calls the reduce trigger for each envelope" do
      Sidekiq::Testing.inline! do
        MailCannon::EnvelopeMapReduce.should_receive(:statistics_for_envelope).with(envelope_a.id.to_s).and_return(nil)
        MailCannon::EnvelopeMapReduce.should_receive(:statistics_for_envelope).with(envelope_b.id.to_s).and_return(nil)
        MailCannon::EnvelopeReduceJob.perform_async([envelope_a.id, envelope_b.id])
      end
    end
  end
end
