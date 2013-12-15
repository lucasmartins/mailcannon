class MailCannon::SingleBarrel
  include Sidekiq::Worker

  def perform(envelope_id)
    aggregator = Librato::Metrics::Aggregator.new
    aggregator.time 'mailgun.shooter.perform' do
      envelope_id = envelope_id['$oid'] if envelope_id['$oid']
      puts "sending Mailgun::Envelope.find('#{envelope_id}')"
    
      begin
        envelope = Mailgun::Envelope.find(envelope_id)
        if envelope.valid?
          response = envelope.send!
          unless response==true
            raise response
          end
        end  
      rescue Exception => e
        puts "unable to send Mailgun::Envelope.find(#{envelope_id})"
        puts e.backtrace
      end
    end
    aggregator.submit
  end
end