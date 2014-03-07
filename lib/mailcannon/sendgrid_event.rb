class MailCannon::SendgridEvent
  include Mongoid::Document
  field :envelope_id, type: String
  field :email, type: String
  field :timestamp, type: String
  field :unique_arg, type: String
  field :event, type: String
  
  def self.insert_bulk(tha_huge_string)
    MailCannon::SendgridEvent.collection.insert(tha_huge_string)
  end
end