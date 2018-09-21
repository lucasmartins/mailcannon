require "spec_helper"

describe MailCannon, "::config" do
  it "returns a valid configuration Hash" do
    config = MailCannon.config("templates")
    expect(config).to be_a_kind_of(Hash)
    expect(config).to have_key("auto_post")
  end
end
