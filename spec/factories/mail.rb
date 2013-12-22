FactoryGirl.define do
  factory :mail, class: MailCannon::Mail do
    text  "Hello %name%, If you can't read the HTML content, you're screwed!"
    html "<html><body><p>You should see what happens when your email client can't read HTML content.</p></body></html>"
  end
end
