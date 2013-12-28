FactoryGirl.define do
  factory :envelope, class: MailCannon::Envelope do
    from 'mailcannon@railsonthebeach.com'
    to ['mailcannon@railsnapraia.com']
    subject 'Test'
    mail MailCannon::Mail.new(text: "Hello %name%, If you can't read the HTML content, you're screwed!", html: "<html><body><p>You should see what happens when your email client can't read HTML content.</p></body></html>")
  end

  factory :envelope_multi, class: MailCannon::Envelope do
    from 'mailcannon@railsonthebeach.com'
    to [
      'mailcannon@railsnapraia.com',
      'lucasmartins@railsnapraia.com',
      'contact@railsonthebeach.com']
    substitutions [
      '%name%'=>[
        'Mail Cannon',
        'Lucas Martins',
        'Contact']
    ]
    subject 'Test'
  end
end
