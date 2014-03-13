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
      consolidated[i]["targets"] << new_statistics[i]["targets"]
    end
    consolidated
  end

  def self.map
    %Q{
      function () {
        emit(this.envelope_id, { target_id: this.target_id, event: this.event });
      }
    }
  end

  def self.reduce
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
end
