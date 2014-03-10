class MailCannon::MapReduce
  # gets the events from the generic event collection into the right envelope 
    def self.grab_events_for_envelope(id)
    #TODO em lotes
    events = MailCannon::SendgridEvent.where(envelope_id: id)
    embedded_events = events.map { |e| MailCannon::EmbeddedSendgridEvent.new(e.attributes.except!("_id")) }
    events.destroy_all
    envelope = MailCannon::Envelope.find(id)
    envelope.embedded_sendgrid_events.concat(embedded_events)
  end
end

=begin
  
map = %Q{
  function() {
    emit(this.name, { likes: this.likes });
  }
}

reduce = %Q{
  function(key, values) {
    var result = { likes: 0 };
    values.forEach(function(value) {
      result.likes += value.likes;
    });
    return result;
  }
}

Band.where(:likes.gt => 100).map_reduce(map, reduce).out(inline: true)


Queue.
  where(pending: true).
  asc(:created_at).
  find_and_modify({ "$set" => { pending: false }}, new: true)

=end