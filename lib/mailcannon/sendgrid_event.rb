class MailCannon::SendgridEvent
  include Mongoid::Document
  field :envelope_id, type: String
  field :envelope_bag_id, type: String
  field :email, type: String
  field :timestamp, type: String
  field :unique_arg, type: String
  field :event, type: String
  field :processed, type: Boolean, default: nil
  
  belongs_to :envelope
  belongs_to :envelope_bag

  def self.insert_bulk(tha_huge_string)
    MailCannon::SendgridEvent.collection.insert(tha_huge_string)
  end
end