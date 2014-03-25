# This worker handles Envelopes dispatch
class MailCannon::Barrel
  include Sidekiq::Worker
  
  def perform(envelope_id)
    envelope_id = envelope_id['$oid'] if envelope_id['$oid']
    shoot!(envelope_id)
  end

  private
  def shoot!(envelope_id)
    logger.info "sending MailCannon::Envelope.find('#{envelope_id}')"
    begin
      envelope = MailCannon::Envelope.find(envelope_id.to_s)
      if envelope.valid?
        response = envelope.send!
        unless response==true
          raise response
        end
      end
    rescue Mongoid::Errors::DocumentNotFound
      logger.error "unable to find the document MailCannon::Envelope.find('#{envelope_id}')"
    rescue Exception => e
      logger.error "unable to send MailCannon::Envelope.find('#{envelope_id}')\n#{e.backtrace}"
    end
  end
end