class MailCannon::Stamp
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :envelope, index: true
  
  field :code, type: Integer, default: 0
  
  validate :code, :envelope, presence: true
  
  def event
    MailCannon::Event.from_code(self.code)
  end
end

# stamp = MailCannon::Stamp.new({code: 3})
