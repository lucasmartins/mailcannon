class MailCannon::Mail
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :envelope, index: true
  
  field :text, type: String
  field :html, type: String
  
  validate :text, presence: true
end

# MailCannon::Mail.new({text: "If you can't read the HTML content, you're screwed!", html: "<html><body><p>You should see what happens when your email client can't read HTML content.</p></body></html>"})
