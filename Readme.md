[![Gem version](https://badge.fury.io/rb/mailcannon.png)](http://rubygems.org/gems/mailcannon) [![Code Climate](https://codeclimate.com/github/mailcannon/mailcannon.png)](https://codeclimate.com/github/mailcannon/mailcannon) [![Build Status](https://travis-ci.org/mailcannon/mailcannon.png?branch=master)](https://travis-ci.org/mailcannon/mailcannon) [![Coverage Status](https://coveralls.io/repos/lucasmartins/mailcannon/badge.png)](https://coveralls.io/r/mailcannon/mailcannon) [![Dependency Status](https://gemnasium.com/mailcannon/mailcannon.png)](https://gemnasium.com/mailcannon/mailcannon) [[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/mailcannon/mailcannon/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

![MailCannon_logo](http://blog.railsnapraia.com/images/mailcannon_seal_128.png)

MailCannon
==========

Although this is a **WORK IN PROGRESS**, we're rolling it out to **production** with no issues for now at [Resultados Digitais](http://resultadosdigitais.com.br/).

This Gem relies heavily on both [Sidekiq](https://github.com/mperham/sidekiq) and Celluloid Gems, you are encouraged to use it anywhere with Ruby (a http interface is on the Roadmap ).

This Gem provides a worker ready for deploy cooked with [MongoDB](http://www.mongodb.org/) + [Mongoid](https://github.com/mongoid/mongoid) + [Sidekiq](https://github.com/mperham/sidekiq) + [Rubinius](http://rubini.us/) (feel free to use on MRI and jRuby as well).

For production deployment, you should take a look at both [MailCannon Outpost](https://github.com/lucasmartins/mailcannon-outpost) and [MailCannon Monitor](https://github.com/lucasmartins/mailcannon-monitor) projects.

Install
=======

You can:
```
  $ gem install mailcannon
```

Or just add it to your Gemfile
```ruby
  gem 'mailcannon'
```

Use
===

Create a `MailCannon::Envelope`:
```ruby
envelope = MailCannon::Envelope.create(
  from: 'test@mailcannon.com',
  to: [{email: 'lucasmartins@railsnapraia.com', name: 'Lucas Martins'}],
  subject: 'Test',
  mail: MailCannon::Mail.new(text: 'you will see this when no HTML reader is available', html: 'this should be an HTML'))

envelope.post!
```

### Campaign abstraction

Create a `MailCannon::EnvelopeBag` and add Envelopes to it:
```ruby
envelope_bag = MailCannon::EnvelopeBag.new(integration_code: 'my-cool-campaign')
envelope = MailCannon::Envelope.create(
  from: 'test@mailcannon.com',
  to: [{email: 'lucasmartins@railsnapraia.com', name: 'Lucas Martins'}],
  subject: 'Test',
  mail: MailCannon::Mail.new(text: 'you will see this when no HTML reader is available', html: 'this should be an HTML'))
envelope_bag.push envelope
# envelope_bag.push ...
envelope_bag.post!
```

### Multiple Sendgrid Accounts

You can pass an auth Hash to the `Envelope` and/or `EnvelopeBag`, the `Envelope` auth will always override the Bag's auth.

```ruby
envelope_bag = MailCannon::EnvelopeBag.new(auth: {username: 'shared-account',password: '123'})
envelope = MailCannon::Envelope.create(
  auth: {username: 'hot-account',password: '456'}
  from: 'test@mailcannon.com',
  to: [{email: 'lucasmartins@railsnapraia.com', name: 'Lucas Martins'}],
  subject: 'Test',
  mail: MailCannon::Mail.new(text: 'you will see this when no HTML reader is available', html: 'this should be an HTML'))
envelope_bag.push envelope
envelope_bag.post! # this will be sent using the 'hot-account'.
```

### Configuration file
If you are on Rails, run the following command to generate a config file:

`$ rails g mailcannon:config`

Otherwise, just copy the template file:

```bash
$ cd my-project
$ cp `bundle show mailcannon`/templates/config/mailcannon.yml config/
```

Edit the file to meet your environemnt needs.

Check the [specs](https://github.com/lucasmartins/mailcannon/tree/master/spec) to see the testing example, it will surely make it clearer.

Docs
====
You should check the [factories](https://github.com/lucasmartins/mailcannon/tree/master/spec/factories) to learn what you need to build your objects, and the [tests](https://github.com/lucasmartins/mailcannon/tree/master/spec/mailcannon) to learn how to use them. But hey, we have docs [right here](http://rdoc.info/github/lucasmartins/mailcannon/master/frames).

Roadmap
=======

- Statistics (Map&Reduce awesomeness);
- Memory optimization (focused on MailCannon Outpost);
- HTTP (webservice) interface - so you don't need to be coding Ruby to use it!;
- New service adapter (Mandrill?);

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
