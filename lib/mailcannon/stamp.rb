class Mailgun::Stamp
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :envelope, index: true
  
  field :code, type: Integer, default: 0
  
  validate :code, :envelope, presence: true
  
  def event
    Mailgun::Event.from_code(self.code)
  end
end

# stamp = Mailgun::Stamp.new({code: 3})
