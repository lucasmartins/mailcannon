FactoryGirl.define do
  factory :envelope, class: MailCannon::Envelope do
    from 'test@mailcannon.com'
    to 'lucasmartins@railsnapraia.com'
    subject 'Test'
    mail factory: :mail
  end
end
