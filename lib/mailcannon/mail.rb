class MailCannon::Mail
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :envelope, index: true
  
  field :text, type: String
  field :html, type: String
  
  validate :text, presence: true
end
