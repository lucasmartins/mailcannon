[![Gem version](https://badge.fury.io/rb/mailcannon.png)](http://rubygems.org/gems/mailcannon) [![Code Climate](https://codeclimate.com/github/mailcannon/mailcannon.png)](https://codeclimate.com/github/mailcannon/mailcannon) [![Build Status](https://travis-ci.org/mailcannon/mailcannon.png?branch=master)](https://travis-ci.org/mailcannon/mailcannon) [![Coverage Status](https://coveralls.io/repos/mailcannon/mailcannon/badge.png)](https://coveralls.io/r/mailcannon/mailcannon) [![Dependency Status](https://gemnasium.com/mailcannon/mailcannon.png)](https://gemnasium.com/mailcannon/mailcannon) [![Inline docs](http://inch-ci.org/github/mailcannon/mailcannon.png)](http://inch-ci.org/github/mailcannon/mailcannon) [![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/mailcannon/mailcannon/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

![MailCannon_logo](https://avatars1.githubusercontent.com/u/7103902?v=3&s=128)

MailCannon
==========

This Gem relies heavily on [Sidekiq](https://github.com/mperham/sidekiq), you are encouraged to use it anywhere with Ruby (a http interface is on the Roadmap ). You REALLY should buy [Sidekiq's Pro](http://sidekiq.org/pro/) license for serious deployments, check it out.

This Gem provides a worker ready for deploy cooked with [MongoDB](http://www.mongodb.org/) + [Mongoid](https://github.com/mongoid/mongoid) + [Sidekiq](https://github.com/mperham/sidekiq) + [Rubinius](http://rubini.us/) (feel free to use on MRI and jRuby as well).

For production deployment, you should take a look at both [MailCannon Outpost](https://github.com/mailcannon/mailcannon-outpost) and [MailCannon Monitor](https://github.com/mailcannon/mailcannon-monitor) projects.

You can check the [changelog here](https://github.com/mailcannon/mailcannon/Changelog.md).

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

Check the [specs](https://github.com/mailcannon/mailcannon/tree/master/spec) to see the testing example, it will surely make it clearer.

### Statistics & MapReduce

MailCannon provides statistics calculation/reduce for the events related to an `Envelope`, like `open`,`click`,`spam`, etc. Assuming you have your Outpost running properly (running reduce jobs), you can access the data through the `envelope.stats` method to get the following hash:

```ruby
{
  "posted"=>{"count"=>0.0, "targets"=>[]},
  "processed"=>{"count"=>0.0, "targets"=>[]},
  "delivered"=>{"count"=>1.0, "targets"=>["1"]},
  "open"=>{"count"=>1.0, "targets"=>["2"]},
  "click"=>{"count"=>0.0, "targets"=>[]},
  "deferred"=>{"count"=>0.0, "targets"=>[]},
  "spam_report"=>{"count"=>0.0, "targets"=>[]},
  "spam"=>{"count"=>0.0, "targets"=>[]},
  "unsubscribe"=>{"count"=>0.0, "targets"=>[]},
  "drop"=>{"count"=>0.0, "targets"=>[]},
  "bounce"=>{"count"=>1.0, "targets"=>["3"]}
}
```

You can trigger the reduce operation directly with `envelope.reduce_statistics`.

**Targets** are your __glue_id__ to link this data inside your own application, we use it as the "Contact#id" so we can show witch `Contact` has received, read, or clicked the email.

Repeating events on the same target will increase the array: `"click"=>{"count"=>3.0, "targets"=>["3","3","3"]}`

Docs
====
You should check the [factories](https://github.com/mailcannon/mailcannon/tree/master/spec/factories) to learn what you need to build your objects, and the [tests](https://github.com/mailcannon/mailcannon/tree/master/spec/mailcannon) to learn how to use them. But hey, we have docs [right here](http://rdoc.info/github/mailcannon/mailcannon/master/frames).

Roadmap
=======

- Load testing;
- Webhook service to receive Sendgrid events;
- Memory optimization (focused on MailCannon Outpost);
- HTTP (webservice) interface - so you don't need to be coding Ruby to use it!;

Contribute
==========

Just fork [MailCannon](https://github.com/mailcannon/mailcannon), add your feature+spec, and make a pull request. **DO NOT** mess up with the version file though.
  
Support
=======

This is an opensource project so don't expect premium support, but don't be shy, post any troubles you're having in the [Issues](https://github.com/mailcannon/mailcannon/issues) page and we'll do what we can to help.

License
=======

Please see [LICENSE](https://github.com/mailcannon/mailcannon/blob/master/LICENSE) for licensing details.
