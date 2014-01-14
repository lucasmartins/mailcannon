FactoryGirl.define do
  factory :empty_envelope_bag, class: MailCannon::EnvelopeBag do
    envelopes []

    factory :filled_envelope_bag, class: MailCannon::EnvelopeBag do
      # This factories will be inconsistent on tests running post! at the same spec
      envelope_a = FactoryGirl.build(:envelope)
      envelope_b = FactoryGirl.build(:envelope_multi)
      envelopes [envelope_a,envelope_b]
    end

  end
end
