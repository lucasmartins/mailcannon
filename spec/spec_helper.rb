require 'pry'
require 'pry-nav'
require "mailcannon"
require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'
require "pathname"
require 'database_cleaner'
require 'factory_girl'
require 'vcr'
require 'webmock'
require 'webmock/rspec'
require 'sidekiq/testing'

if ENV['TRAVIS']==true
  begin
    require 'coveralls'
    Coveralls.wear!
  rescue Exception => e
    puts "Coveralls not available!"
  end  
end

SPECDIR = Pathname.new(File.dirname(__FILE__))
TMPDIR = SPECDIR.join("tmp")

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|r| require r}
Dir[File.dirname(__FILE__) + "/factories/**/*.rb"].each {|r| require r}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = :random
  config.include FactoryGirl::Syntax::Methods
  config.before { FileUtils.mkdir_p(TMPDIR) }
  config.mock_with :rspec
  
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end
  WebMock.disable_net_connect!
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

Mongoid.load!("spec/support/mongoid.yml", 'test')
MailCannon.config('templates')