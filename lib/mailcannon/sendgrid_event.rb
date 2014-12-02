class MailCannon::SendgridEvent
  include Mongoid::Document

  field :email, type: String
  field :timestamp, type: String
  field :unique_arg, type: String
  field :event, type: String
  field :type, type: String

  belongs_to :envelope, index: true
  belongs_to :envelope_bag, index: true

  def self.insert_bulk(tha_huge_string)
    MailCannon::SendgridEvent.with(safe: true).collection.insert(tha_huge_string)
  end
end
