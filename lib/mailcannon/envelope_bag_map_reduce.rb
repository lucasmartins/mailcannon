module MailCannon::EnvelopeBagMapReduce
  module ClassMethods
    def reduce_statistics_for_envelope_bag(id)
      events = MailCannon::SendgridEvent.where(:envelope_bag_id => id, :event.in => MailCannon::EnvelopeBag::EVENTS_TO_PROCESS)
      result = events.map_reduce(self.js_map, self.js_reduce).out(merge: "mail_cannon_envelope_bag_statistics").finalize(self.js_finalize)

      MailCannon::EnvelopeBag.find(id).mark_stats_processed!

      {raw: result.raw, count: events.count}
    end

    def statistics_for_envelope(id)
      self.stats
    end

    def js_map_reduce_path(file)
      File.expand_path("reduces/#{file}", File.dirname(__FILE__))
    end

    def js_map
      @js_map ||= File.read(js_map_reduce_path("envelope_bag_map.js"))
      #TODO cache this
    end

    def js_reduce
      @js_reduce ||= File.read(js_map_reduce_path("envelope_bag_reduce.js"))
      #TODO cache this
    end

    def js_finalize
      @js_finalize ||= File.read(js_map_reduce_path("envelope_bag_finalize.js"))
      #TODO cache this
    end
  end

  module InstanceMethods
    def reduce_statistics
      self.class.reduce_statistics_for_envelope_bag(self.id)
    end

    def statistics
      self.class.statistics_for_envelope(self.id)
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
