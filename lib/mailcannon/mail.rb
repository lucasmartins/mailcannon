class MailCannon::Mail
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :envelope#, index: true
  
  field :text, type: String
  field :html, type: String
  
  validate :text, presence: true
end
