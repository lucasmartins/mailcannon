class MailCannon::MapReduce
  def self.grab_events_for_envelope(id)
    # processed: (nil:new), (false:locked), (true: processed)
    MailCannon::SendgridEvent.where(envelope_id: id, processed: nil).update_all(processed: false)
    events = MailCannon::SendgridEvent.where(envelope_id: id, processed: false).to_a
    envelope = MailCannon::Envelope.find(id)
    envelope.sendgrid_events.concat(events) unless events.empty?
  end
end
