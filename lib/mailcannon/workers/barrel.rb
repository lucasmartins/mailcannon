# This worker handles Envelopes dispatch
class MailCannon::Barrel
  include Sidekiq::Worker

  sidekiq_options queue: :mail_delivery

  def perform(envelope_id)
    envelope_id = envelope_id["$oid"] if envelope_id["$oid"]
    shoot!(envelope_id)
  end

  private

  def shoot!(envelope_id)
    logger.info "sending MailCannon::Envelope.find('#{envelope_id}')"
    begin
      envelope = MailCannon::Envelope.find(envelope_id.to_s)
      logger.info "envelope_id:#{envelope_id} envelope:#{envelope}"
      if envelope.valid?
        response = envelope.send!
        logger.info "valid envelope_id:#{envelope_id} response:#{response}"
        raise response unless response == true
      end
    rescue Mongoid::Errors::DocumentNotFound => e
      logger.error "unable to find the document MailCannon::Envelope.find('#{envelope_id}')"
      raise e
    rescue Exception => e
      logger.error "unable to send MailCannon::Envelope.find('#{envelope_id}') #{e.message}"
      raise e
    end
  end
end
