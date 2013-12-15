FactoryGirl.define do
  factory :stamp, class: MailCannon::Stamp do
    code 0
    envelope factory: :envelope 
  end
end
