
$LOAD_PATH.push File.expand_path("lib", __dir__)
require "mailcannon/version"

Gem::Specification.new do |s|
  s.name                  = "mailcannon"
  s.version               = MailCannon::Version::STRING
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.3"
  s.authors               = ["Lucas Martins"]
  s.email                 = ["lucasmartins@railsnapraia.com"]
  s.homepage              = "http://rubygems.org/gems/mailcannon"
  s.summary               = "A mass mailing tool for real threads aficionados"
  s.description           = s.summary
  s.license               = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "mongoid", ">= 5.1.0"
  s.add_dependency "redis"
  s.add_dependency "sendgrid_webapi", "0.0.8"
  s.add_dependency "sidekiq"

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "database_cleaner", ">= 1.4"
  s.add_development_dependency "factory_girl", "~> 4.2.0"
  s.add_development_dependency "fivemat"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">= 3.0.0"
  s.add_development_dependency "rspec-expectations", ">= 3.0.0"
  s.add_development_dependency "rspec-mocks", ">= 3.0.0"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock", ">= 1.8.0", "< 1.16"
  s.add_development_dependency "yard"
end
