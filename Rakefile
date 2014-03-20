require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

task :default => :travis

task :environment do
  require './spec/spec_helper'
end

desc 'Opens a Pry/IRB session with the environment loaded'
task :console => :environment do
  #gotcha!
  Mongoid.load!("spec/support/mongoid.yml", 'development')
  binding.pry
end

task :travis do
  ["rake spec", "rake build"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end
