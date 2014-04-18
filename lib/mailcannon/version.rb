# Keeps the versioning clean and simple.
module MailCannon
  module Version
    MAJOR = 0
    MINOR = 1
    PATCH = 1
    ALPHA = nil # ex: '.pre.1'
    STRING = "#{MAJOR}.#{MINOR}.#{PATCH}#{ALPHA}"
  end
end
