FactoryGirl.define do
  factory :envelope, class: MailCannon::Envelope do
    from 'mailcannon@railsonthebeach.com'
    to [{email: 'mailcannon@railsnapraia.com', name: 'Mail Cannon'}]
    subject 'Test'
    mail MailCannon::Mail.new(text: "Hello %name%, If you can't read the HTML content, you're screwed!", html: "<html><body><p>%name%,<br/><br/>You should see what happens when your email client can't read HTML content.</p></body></html>")

    factory :envelope_multi, class: MailCannon::Envelope do
      from 'mailcannon@railsonthebeach.com'
      to [
        {email: 'mailcannon@railsnapraia.com', name: 'Mail Cannon'},
        {email: 'lucasmartins@railsnapraia.com', name: 'Lucas Martins'},
        {email: 'contact@railsonthebeach.com', name: 'Contact'}
      ]
      subject 'Test'
    end
    
    factory :envelope_wrong_auth, class: MailCannon::Envelope do
      auth({username: 'wrong', password: 'combination'})
    end

    factory :envelope_multi_1k, class: MailCannon::Envelope do
      mails = []
      source = 'lucasmartins+#@railsnapraia.com'
      1000.times.each do |i|
        mails.push source.gsub('#',i.to_s)
      end

      names = []
      source = 'Lucas Martins #'
      1000.times.each do |i|
        names.push source.gsub('#',i.to_s)
      end
      
      to_array = []
      1000.times.each do |i|
        to_array.push({name: names[i], email: mails[i]})
      end
      
      from 'mailcannon@railsonthebeach.com'
      to to_array
      hash = {"%name%"=>names}
      subject 'Test'
    end
  end
end
