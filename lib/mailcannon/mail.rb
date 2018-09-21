# Holds the content of the email, this will be destroyed once the Envelope has been processed.
class MailCannon::Mail
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :envelope

  field :text, type: String
  field :html, type: String

  validates :text, presence: true
end
