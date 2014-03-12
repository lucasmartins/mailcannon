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

  def self.persist_statistics_for_envelope(statistics)
    statistics.each do |statistic|
      envelope = MailCannon::Envelope.find(statistic["_id"])
      envelope.statistics = envelope.statistics.nil?  ? statistics["value"] : merge_statistics(envelope.statistics, statistics["value"])
      envelope.save
    end 
  end

  private

  def self.merge_statistics(consolidated, new_statistics)
    ["posted","processed","delivered", "open", "click","deferred","spam_report","spam","unsubscribe","drop","bounce"].each do |status|
      consolidated[i]["count"] = consolidated[i]["count"] + new_statistics[i]["count"]
      consolidated[i]["leads"] << new_statistics[i]["leads"]
    end
    consolidated
  end

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
      };

      values.forEach(function(value) {
        switch (value['event']) {
          case 'posted':
            result['posted']['count']++;
            result['posted']['leads'].push(value['lead_id']);
          break;
          case 'processed':
            result['processed']['count']++;
            result['processed']['leads'].push(value['lead_id']);
          break;
          case 'delivered':
            result['delivered']['count']++;
            result['delivered']['leads'].push(value['lead_id']);
          break;
          case 'open':
            result['open']['count']++;
            result['open']['leads'].push(value['lead_id']);
          break;
          case 'click':
            result['click']['count']++;
            result['click']['leads'].push(value['lead_id']);
          break;
          case 'deferred':
            result['deferred']['count']++;
            result['deferred']['leads'].push(value['lead_id']);
          break;
          case 'spam_report':
            result['spam_report']['count']++;
            result['spam_report']['leads'].push(value['lead_id']);
          break;
          case 'spam':
            result['spam']['count']++;
            result['spam']['leads'].push(value['lead_id']);
          break;
          case 'unsubscribe':
            result['unsubscribe']['count']++;
            result['unsubscribe']['leads'].push(value['lead_id']);
          break;
          case 'drop':
            result['drop']['count']++;
            result['drop']['leads'].push(value['lead_id']);
          break;
          case 'bounce':
            result['bounce']['count']++;
            result['bounce']['leads'].push(value['lead_id']);
          break;
        }
      });
      return result;
    }
    }
  end
end
