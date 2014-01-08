# This worker handles Envelopes dispatch
class MailCannon::Barrel
  include Sidekiq::Worker

  def perform(envelope_id)
    envelope_id = envelope_id['$oid'] if envelope_id['$oid']
    puts "sending MailCannon::Envelope.find('#{envelope_id}')"
  
    begin
      envelope = MailCannon::Envelope.find(envelope_id)
      if envelope.valid?
        response = envelope.send!
        unless response==true
          raise response
        end
      end  
    rescue Exception => e
      puts "unable to send MailCannon::Envelope.find(#{envelope_id})"
      puts e.backtrace
    end
  end
end