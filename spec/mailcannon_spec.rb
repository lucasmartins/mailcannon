require "spec_helper"

describe MailCannon, "::config" do
  it "returns a valid configuration Hash" do
    config = MailCannon.config('templates')
    config.should be_a_kind_of(Hash)
    config.should have_key('auto_post')
  end
end