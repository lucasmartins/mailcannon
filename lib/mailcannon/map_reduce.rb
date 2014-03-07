class MailCannon::MapReduce
  # gets the events from the generic event collection into the right envelope 
  def self.grab_events_for_envelope(id)
    #TODO em lotes
    events = MailCannon::SendgridEvent.where(envelope_id: id).find_and_modify({}, remove: true)
    envelope = MailCannon::Envelope.find(id)
    events.each do |e|
      envelope.sendgrid_events << e
    end
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