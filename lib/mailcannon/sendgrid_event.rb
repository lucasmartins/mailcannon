class MailCannon::SendgridEvent
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  field :email, type: String
  field :timestamp, type: String
  field :unique_arg, type: String
  field :event, type: String
  field :type, type: String

  belongs_to :envelope, index: true
  belongs_to :envelope_bag, index: true

  def self.insert_bulk(tha_huge_string)
    collection_mailcannon_sendgrid_event = MailCannon::SendgridEvent.with(safe: true).collection
    if tha_huge_string.king_of?(Array)
      collection_mailcannon_sendgrid_event.insert_many(tha_huge_string)
    else
      collection_mailcannon_sendgrid_event.insert_one(tha_huge_string)
    end
  end
end
