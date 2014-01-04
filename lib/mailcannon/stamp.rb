class MailCannon::Stamp
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :envelope, index: true
  
  field :code, type: Integer, default: 0
  field :recipient # email address for this "notification"
  validates :code, :envelope, presence: true
  
  def event
    MailCannon::Event.from_code(self.code)
  end
  
  def self.from_code(code)
    if code.is_a? Fixnum
      return MailCannon::Stamp.new({code: code})
    elsif code.is_a? MailCannon::Stamp
      return code
    else # MailCannon::Event::*
      return code.stamp
    end
  end
end
