module MailCannon::EnvelopeMapReduce
  module ClassMethods
    def reduce_statistics_for_envelope(id)
      events = change_events_status_for_envelope(id,nil,:lock)
      result = events.map_reduce(self.js_map, self.js_reduce).out(merge: "mail_cannon_envelope_statistics")
      set_events_to(events,:processed)
      result.raw
    end

    def statistics_for_envelope(id)
      MailCannon::Envelope.stats
    end

    def js_map
      %Q{
        function () {
          emit(this.envelope_id, { target_id: this.target_id, event: this.event });
        }
      }
    end
  
    def js_reduce
      %Q{
        function (key, values) {
        var result = {
          'posted': {
            'count': 0,
            'targets': []
          },
          'processed': {
            'count': 0,
            'targets': []
          },
          'delivered': {
            'count': 0,
            'targets': []
          },
          'open': {
            'count': 0,
            'targets': []
          },
          'click': {
            'count': 0,
            'targets': []
          },
          'deferred': {
            'count': 0,
            'targets': []
          },
          'spam_report': {
            'count': 0,
            'targets': []
          },
          'spam': {
            'count': 0,
            'targets': []
          },
          'unsubscribe': {
            'count': 0,
            'targets': []
          },
          'drop': {
            'count': 0,
            'targets': []
          },
          'bounce': {
            'count': 0,
            'targets': []
          }
        };

        values.forEach(function(value) {
          switch (value['event']) {
            case 'posted':
              result['posted']['count']++;
              result['posted']['targets'].push(value['target_id']);
            break;
            case 'processed':
              result['processed']['count']++;
              result['processed']['targets'].push(value['target_id']);
            break;
            case 'delivered':
              result['delivered']['count']++;
              result['delivered']['targets'].push(value['target_id']);
            break;
            case 'open':
              result['open']['count']++;
              result['open']['targets'].push(value['target_id']);
            break;
            case 'click':
              result['click']['count']++;
              result['click']['targets'].push(value['target_id']);
            break;
            case 'deferred':
              result['deferred']['count']++;
              result['deferred']['targets'].push(value['target_id']);
            break;
            case 'spam_report':
              result['spam_report']['count']++;
              result['spam_report']['targets'].push(value['target_id']);
            break;
            case 'spam':
              result['spam']['count']++;
              result['spam']['targets'].push(value['target_id']);
            break;
            case 'unsubscribe':
              result['unsubscribe']['count']++;
              result['unsubscribe']['targets'].push(value['target_id']);
            break;
            case 'drop':
              result['drop']['count']++;
              result['drop']['targets'].push(value['target_id']);
            break;
            case 'bounce':
              result['bounce']['count']++;
              result['bounce']['targets'].push(value['target_id']);
            break;
          }
        });
        return result;
      }
      }
    end

    # [from|to]sym = :new, :lock, :processed
    def change_events_status_for_envelope(id, from_sym, to_sym)
      from_status = processed_status_for(from_sym)
      to_status = processed_status_for(to_sym)
      if from_sym
        query = MailCannon::SendgridEvent.where(envelope_id: id, processed: from_status)
      else
        query = MailCannon::SendgridEvent.where(envelope_id: id)
      end
      if query.kind_of?(Mongoid::Criteria)
        query.update_all(processed: to_status)
      else
        query.processed=to_status
        query.save
      end
      query
    end

    #private
    def set_events_to(events,status)
      status = processed_status_for(status)
      if events.kind_of?(Mongoid::Criteria)
        events.update_all(processed: status)
      else
        events.processed=status
        events.save
      end
    end

    def processed_status_for(input)
      status_map = {
        lock: false,
        processed: true,
        new: nil
      }
      if [false,true,nil].include?(input)
        status_map = status_map.invert
        raise "Unexpected  input(#{input})" unless status_map.has_key?(input)
      end
      status_map[input]
    end

  end
  
  module InstanceMethods
    def reduce_statistics
      self.class.reduce_statistics_for_envelope(self.id)
    end

    def statistics
      self.class.statistics_for_envelope(self.id)
    end

    def change_events_status(from_sym, to_sym)
      self.set_processed_status_for_envelope(self.id, from_sym, to_sym)
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

