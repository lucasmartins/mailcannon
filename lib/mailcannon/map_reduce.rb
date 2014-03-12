class MailCannon::MapReduce
  def self.grab_events_for_envelope(id)
    # processed: (nil:new), (false:locked), (true: processed)
    MailCannon::SendgridEvent.where(envelope_id: id, processed: nil).update_all(processed: false)
    events = MailCannon::SendgridEvent.where(envelope_id: id, processed: false).to_a
    envelope = MailCannon::Envelope.find(id)
    envelope.sendgrid_events.concat(events) unless events.empty?
  end

  def self.statistics_for_envelope(id)
    MailCannon::SendgridEvent.where(envelope_id: id).map_reduce(MailCannon::MapReduce.map, MailCannon::MapReduce.reduce).out(inline: true)
  end

  #private
  def self.map
    %Q{
      function () {
        emit(this.envelope_id, { lead_id: this.lead_id, event: this.event });
      }
    }
  end

  def self.reduce
    %Q{
      function (key, values) {
      var result = {
        'envelope_statistics': {
          'envelope_id': key,
          'events': {
            'posted': {
              'count': 0,
              'leads': []
            },
            'processed': {
              'count': 0,
              'leads': []
            },
            'delivered': {
              'count': 0,
              'leads': []
            },
            'open': {
              'count': 0,
              'leads': []
            },
            'click': {
              'count': 0,
              'leads': []
            },
            'deferred': {
              'count': 0,
              'leads': []
            },
            'spam_report': {
              'count': 0,
              'leads': []
            },
            'spam': {
              'count': 0,
              'leads': []
            },
            'unsubscribe': {
              'count': 0,
              'leads': []
            },
            'drop': {
              'count': 0,
              'leads': []
            },
            'bounce': {
              'count': 0,
              'leads': []
            }
          }
        }
      };

      values.forEach(function(value) {
        switch (value['event']) {
          case 'posted':
            result['envelope_statistics']['events']['posted']['count']++;
            result['envelope_statistics']['events']['posted']['leads'].push(value['lead_id']);
          break;
          case 'processed':
            result['envelope_statistics']['events']['processed']['count']++;
            result['envelope_statistics']['events']['processed']['leads'].push(value['lead_id']);
          break;
          case 'delivered':
            result['envelope_statistics']['events']['delivered']['count']++;
            result['envelope_statistics']['events']['delivered']['leads'].push(value['lead_id']);
          break;
          case 'open':
            result['envelope_statistics']['events']['open']['count']++;
            result['envelope_statistics']['events']['open']['leads'].push(value['lead_id']);
          break;
          case 'click':
            result['envelope_statistics']['events']['click']['count']++;
            result['envelope_statistics']['events']['click']['leads'].push(value['lead_id']);
          break;
          case 'deferred':
            result['envelope_statistics']['events']['deferred']['count']++;
            result['envelope_statistics']['events']['deferred']['leads'].push(value['lead_id']);
          break;
          case 'spam_report':
            result['envelope_statistics']['events']['spam_report']['count']++;
            result['envelope_statistics']['events']['spam_report']['leads'].push(value['lead_id']);
          break;
          case 'spam':
            result['envelope_statistics']['events']['spam']['count']++;
            result['envelope_statistics']['events']['spam']['leads'].push(value['lead_id']);
          break;
          case 'unsubscribe':
            result['envelope_statistics']['events']['unsubscribe']['count']++;
            result['envelope_statistics']['events']['unsubscribe']['leads'].push(value['lead_id']);
          break;
          case 'drop':
            result['envelope_statistics']['events']['drop']['count']++;
            result['envelope_statistics']['events']['drop']['leads'].push(value['lead_id']);
          break;
          case 'bounce':
            result['envelope_statistics']['events']['bounce']['count']++;
            result['envelope_statistics']['events']['bounce']['leads'].push(value['lead_id']);
          break;
        }
      });
      return result;
    }
    }
  end
end
