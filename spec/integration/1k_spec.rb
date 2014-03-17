require "spec_helper"
require 'benchmark'

describe "shoot 1k emails!" do
  let!(:envelope_a) { build(:envelope_multi_1k) }
  #let!(:envelope_b) { build(:envelope_multi_1k) }
  #let!(:envelope_c) { build(:envelope_multi_1k) }
  it "sends http request for Sendgrid web API" do
    VCR.use_cassette('mailcannon_integration_1k') do
      Sidekiq::Testing.inline! do
        bm = Benchmark.measure do
          envelope_a.send_bulk!
        end
        puts "1k test real time: #{bm.real}"
        # Travis has been showing unstable performance, not feasible to include performance tests.
        unless ENV['TRAVIS']
          expect(bm.real<0.3).to be_true
        end
      end
    end
  end
end
