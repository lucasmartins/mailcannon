require "spec_helper"

describe 'X-SMTPAPI compatibility' do
  describe "xsmtpapi for bulk" do
    # This should guarantee the expected behavior for the following api:
    #   http://sendgrid.com/docs/API_Reference/SMTP_API/unique_arguments.html
    context "generates expected xsmtpapi for #post!" do
      let(:envelope) { build(:envelope_multi, xsmtpapi: { "sub" => { "-email-id-" => ["314159","271828"] }, "unique_args" => { "email_id" => "-email-id-"} }) }

      it "returns true" do
        VCR.use_cassette('mailcannon_adapter_sendgrid_send_bulk') do
          Sidekiq::Testing.inline! do
            envelope.post!
          end
        end
        envelope.reload # content is changed inside the Adapter module
        expect(envelope.xsmtpapi['to']).to match_array ['mailcannon@railsnapraia.com', 'contact@railsonthebeach.com', 'lucasmartins@railsnapraia.com']
        expect(envelope.xsmtpapi).to have_key('sub')
        expect(envelope.xsmtpapi['sub']).to have_key('-email-id-')
        expect(envelope.xsmtpapi).to have_key('unique_args')
      end
    end
  end
end
