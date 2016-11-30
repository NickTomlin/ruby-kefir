kefir [![Build Status](https://travis-ci.org/NickTomlin/kefir.png?branch=master)](https://travis-ci.org/NickTomlin/kefir) [![Gem Version](https://badge.fury.io/rb/kefir.svg)](https://badge.fury.io/rb/kefir)
===

Simple configuration for your Gem or application. A ruby port of [conf](https://www.npmjs.com/package/conf).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kefir'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kefir

## Usage

```
require 'kefir'

config = Kefier.config('my_gem')
api_key = config.get(:api_key)

config.set(:api_key, api_key + '!')

# write your changes
config.persist
```

`get` and `set` can accept multiple keys for nested paths:

```
config.set(:my, :nested, :value, 'hello!')
value = config.get(:my, :nested, :value)

expect(value).to eq('hello!')
```

## Contributing

1. Fork it ( https://github.com/nicktomlin/kefir/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests `rake`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
