module MailCannon::EnvelopeBagMapReduce
  module ClassMethods
    def reduce_statistics_for_envelope_bag(id)
      events = change_events_status_for_envelope_bag(id, nil, :lock)
      result = events.map_reduce(self.js_map, self.js_reduce).out(merge: "mail_cannon_envelope_bag_statistics")
      set_events_to(events,:processed)
      {raw: result.raw, count: events.count}
    end

    def statistics_for_envelope(id)
      self.stats
    end

    def js_map
      #TODO cache this
      @js_map ||= File.read('lib/mailcannon/reduces/envelope_bag_map.js')
    end

    def js_reduce
      #TODO cache this
      @js_reduce ||= File.read('lib/mailcannon/reduces/envelope_bag_reduce.js')
    end

    # [from|to]sym = :new, :lock, :processed
    def change_events_status_for_envelope_bag(id, from_sym, to_sym)
      from_status = processed_status_for(from_sym)
      to_status = processed_status_for(to_sym)
      if from_sym
        query = MailCannon::SendgridEvent.where(envelope_bag_id: id, processed: from_status)
      else
        query = MailCannon::SendgridEvent.where(envelope_bag_id: id)
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
      self.class.reduce_statistics_for_envelope_bag(self.id)
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

