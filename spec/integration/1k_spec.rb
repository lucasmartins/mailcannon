require "spec_helper"
require 'benchmark'


describe "shoot 1k emails!", sidekiq: :inline do
  let!(:envelope_a) { build(:envelope_multi_1k) }
  it "sends http request for Sendgrid web API" do
    VCR.use_cassette('mailcannon_integration_1k') do
      bm = Benchmark.measure do
        envelope_a.post!
      end
      puts "1k test real time: #{bm.real}"
      expect(envelope_a.reload.processed?).to be true

      # Travis has been showing unstable performance, not feasible to include performance tests.
      # The performance varies from machine to machine, specially when using dedicated servers for each service.
      if ENV['PERFORMANCE_TEST']
        expect(bm.real<0.2).to be true
      end
    end
  end
end

if ENV['SENDGRID_PASSWORD'] && !ENV['CI']
  describe "shoot 1k real (@sink) emails!" do
    let!(:envelope_a) { build(:envelope_multi_1k) }
    it "sends http request for Sendgrid web API" do
      Sidekiq::Testing.inline! do
        envelope_a.post!
        expect(envelope_a.reload.processed?).to be_true
      end
    end
  end
end
