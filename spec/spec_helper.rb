require 'pry'
require 'pry-nav'
require "mailcannon"
require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'
require "pathname"
require 'database_cleaner'
require 'factory_girl'

SPECDIR = Pathname.new(File.dirname(__FILE__))
TMPDIR = SPECDIR.join("tmp")

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|r| require r}
Dir[File.dirname(__FILE__) + "/factories/**/*.rb"].each {|r| require r}

RSpec.configure do |config|
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
  
end

Mongoid.load!("spec/support/mongoid.yml", ENV['RACK_ENV'])