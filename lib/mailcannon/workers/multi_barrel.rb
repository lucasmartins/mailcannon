class MailCannon::MultiBarrel
  include Sidekiq::Worker

  def perform
    raise 'Worker unavailable!'
    # search pending emails in the db
    # build the xsmtpapi Hash
    # bulk_send!
    # callbacks
  end
end