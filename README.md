Dev::Consul
===========

`Dev::Consul` is a simple wrapper around the Consul binary for development and testing. It bundles all of the published Consul binaries at `Dev::Consul::VERSION` and runs the correct build for the local system.

Note that `Dev::Consul`'s version follows that of Consul.

Consul is maintained by Hashicorp. Please see https://www.consul.io/ for details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dev-consul'
```

Or Gemspec:

```ruby
spec.add_development_dependency 'dev-consul', '0.6.4'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dev-consul

## Usage

Run `bundle exec rake` to launch a local instance of Consul.

To integrate into tests:

```ruby
require 'dev/consul'

RSpec.configure do |config|
  config.before(:suite) do
    Dev::Consul.run

    ## Mute output once the consul server is running
    Dev::Consul.output(false)
  end

  config.after(:suite) do
    Dev::Consul.stop
  end

  ## ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rapid7/dev-consul.
