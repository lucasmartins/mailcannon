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
    MailCannon::SendgridEvent.collection.insert_many(parse_to_array(tha_huge_string))
  end

  private

  def parse_to_array(value)
    return value if value.kind_of?(Array)
    [value]
  end
end
