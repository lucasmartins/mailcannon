FactoryGirl.define do
  factory :envelope, class: MailCannon::Envelope do
    from 'mailcannon@railsonthebeach.com'
    to ['mailcannon@railsnapraia.com']
    subject 'Test'
    mail factory: :mail
  end

  factory :envelope_multi, class: MailCannon::Envelope do
    from 'mailcannon@railsonthebeach.com'
    to [
      'mailcannon@railsnapraia.com',
      'lucasmartins@railsnapraia.com',
      'contact@railsonthebeach.com']
    substitutions [
      'Mail Cannon',
      'Lucas Martins',
      'Contact'
    ]
    subject 'Test'
    mail factory: :mail
  end
end
