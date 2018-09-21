require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

task :environment do
  require "./spec/spec_helper"
end

desc "Opens a Pry/IRB session with the environment loaded"
task console: :environment do
  # gotcha!
  Mongoid.load!("spec/support/mongoid.yml", "development")
  binding.pry
end
