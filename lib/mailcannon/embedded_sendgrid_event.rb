class MailCannon::EmbeddedSendgridEvent
  include Mongoid::Document
  field :email, type: String
  field :timestamp, type: String
  field :unique_arg, type: String
  field :event, type: String
  
  embedded_in :envelope
  
  def self.insert_bulk(tha_huge_string)
    MailCannon::SendgridEvent.collection.insert(tha_huge_string)
  end
end