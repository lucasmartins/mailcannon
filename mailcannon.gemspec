# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mailcannon/version"

Gem::Specification.new do |s|
  s.name                  = "mailcannon"
  s.version               = MailCannon::Version::STRING
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.9.3"
  s.authors               = ["Lucas Martins"]
  s.email                 = ["lucasmartins@railsnapraia.com"]
  s.homepage              = "http://rubygems.org/gems/mailcannon"
  s.summary               = "A mass mailing tool for real threads aficionados"
  s.description           = s.summary
  s.license               = "LGPL-3.0

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  if RUBY_ENGINE=='rbx'
    s.add_dependency 'rubysl'
  end
  if RUBY_PLATFORM=='ruby'
    s.add_dependency 'yajl-ruby'
  end
  if RUBY_PLATFORM=='jruby'
    s.add_dependency 'jruby-openssl'
  end

  s.add_runtime_dependency 'activemodel', '>= 3.0.0'

  s.add_dependency 'redis'
  s.add_dependency 'mongoid','3.1.6'
  s.add_dependency 'sidekiq', '2.17.7'
  s.add_dependency 'sendgrid_webapi', '0.0.3'
  s.add_dependency 'json-schema'
  s.add_dependency 'librato-metrics'

  s.add_development_dependency "vcr"
  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rspec", '>= 3.0.0'
  s.add_development_dependency "rspec-mocks", '>= 3.0.0'
  s.add_development_dependency "rspec-expectations", '>= 3.0.0'
  s.add_development_dependency "webmock", '>= 1.8.0', '< 1.16'
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_girl", "~> 4.2.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "yard"

  if RUBY_ENGINE == 'ruby'
    s.add_development_dependency 'coveralls'
  end
end
