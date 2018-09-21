# Manages the mailing Events, very tricky.
class MailCannon::Event
  EVENTS = %w[
    posted
    processed
    delivered
    open
    click
    deferred
    spam_report
    spam
    unsubscribe
    drop
    bounce
  ].freeze

  EVENTS.each do |module_name|
    MailCannon::Event.class_eval <<RUBY
module #{module_name.camelize}
  def self.to_i
    #{EVENTS.index(module_name)}
  end
  def self.to_s
    "#{module_name}"
  end
  def self.stamp
    MailCannon::Stamp.new({code: #{EVENTS.index(module_name)} })
  end
  def self.to_stamp
    self.stamp
  end
end
RUBY
  end # ends each loop

  def self.from_code(code)
    raise "code must be an Integer or String!" unless code.is_a?(Integer) || code.is_a?(String)
    if code.is_a?(Integer)
      return eval_module(EVENTS[code])
    else
      return eval_module(code)
    end
  end

  private

  def self.eval_module(code)
    if EVENTS.include?(code)
      eval("MailCannon::Event::#{code.camelize}")
    else
      raise "invalid code. Use one of the following: #{EVENTS}"
    end
  end
end
