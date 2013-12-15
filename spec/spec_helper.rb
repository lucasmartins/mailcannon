require 'pry'
require 'pry-nav'
require "mailcannon"
require 'rspec'
require 'rspec/mocks'
require "pathname"

SPECDIR = Pathname.new(File.dirname(__FILE__))
TMPDIR = SPECDIR.join("tmp")

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|r| require r}

RSpec.configure do |config|
  config.before { FileUtils.mkdir_p(TMPDIR) }
end
