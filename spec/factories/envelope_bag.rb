FactoryGirl.define do
  factory :empty_envelope_bag, class: MailCannon::EnvelopeBag do
    envelopes []

    factory :filled_envelope_bag, class: MailCannon::EnvelopeBag do
      envelopes {[FactoryGirl.build(:envelope),FactoryGirl.build(:envelope_multi)]}
    end

  end
end
