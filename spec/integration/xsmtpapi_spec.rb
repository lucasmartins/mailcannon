require "spec_helper"

describe 'X-SMTPAPI compatibility' do
  describe "xsmtpapi for bulk" do
    context "generates expected xsmtpapi for #post!" do
      let(:envelope) { build(:envelope_multi, xsmtpapi: { "unique_args" => { "userid" => "1123", "template" => "welcome" }}) }

      it "returns true" do
        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          Sidekiq::Testing.inline! do
            envelope.post!
          end
        end
        envelope.reload # content is changed inside the Adapter module
        #binding.pry
        expect(envelope.xsmtpapi['to']).to match_array ['mailcannon@railsnapraia.com', 'contact@railsonthebeach.com', 'lucasmartins@railsnapraia.com']
      end
    end
  end
end
