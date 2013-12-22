[![Gem version](https://badge.fury.io/rb/mailcannon.png)](http://rubygems.org/gems/mailcannon) [![Code Climate](https://codeclimate.com/github/lucasmartins/mailcannon.png)](https://codeclimate.com/github/lucasmartins/mailcannon) [![Build Status](https://travis-ci.org/lucasmartins/mailcannon.png?branch=master)](https://travis-ci.org/lucasmartins/mailcannon) [![Dependency Status](https://gemnasium.com/lucasmartins/mailcannon.png)](https://gemnasium.com/lucasmartins/mailcannon) [![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/lucasmartins/mailcannon/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

MailCannon
==========

This is a **WORK IN PROGRESS**

This Gem relies heavily on both [Sidekiq](https://github.com/mperham/sidekiq) and Celluloid Gems, you are encouraged to use it anywhere with Ruby (a http interface is on the Roadmap ).

This Gem provides workers ready for deploy cooked with [MongoDB](http://www.mongodb.org/) + [Mongoid](https://github.com/mongoid/mongoid) + [Sidekiq](https://github.com/mperham/sidekiq) + [Rubinius](http://rubini.us/) (feel free to use on MRI and jruby as well).

Install
=======

You can:
```
  $ gem install mailcannon
```

Or just add it to your Gemfile
```
  gem 'mailcannon'
```

Use
===

Create a `MailCannon::Envelope`:
```ruby
envelope = MailCannon::Envelope.create(
  from: 'test@mailcannon.com',
  to: 'lucasmartins@railsnapraia.com',
  subject: 'Test',
  mail: MailCannon::Mail.create(text: 'you will see this when no HTML reader is available', html: 'this should be an HTML'))
envelope.send!
```
### Configuration file
If you are on Rails, run the following command to generate a config file:

`$ rails g mailcannon:config`

Edit the file to meet your environemnt needs.

Check the [specs](https://github.com/lucasmartins/mailcannon/tree/master/spec) to see the testing example, it will surely make it clearer.

Contribute
==========

Just fork [MailCannon](https://github.com/lucasmartins/mailcannon), add your feature+spec, and make a pull request. Do not mess up with the version file though.

**NOTICE**: The project is at embrionary stage, breaking changes will apply.

Support
=======

This is an opensource project so don't expect premium support, but don't be shy, post any troubles you're having in the [Issues](https://github.com/lucasmartins/mailcannon/issues) page and we'll do what we can to help.

License
=======

MailCannon is free software under the [FreeBSD license](http://www.freebsd.org/copyright/freebsd-license.html).
