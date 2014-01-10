[![Build Status](https://travis-ci.org/fuzz/moe.png?branch=master)](https://travis-ci.org/fuzz/moe)
[![Code Climate](https://codeclimate.com/github/fuzz/moe.png)](https://codeclimate.com/github/fuzz/moe)
[![Coverage Status](https://coveralls.io/repos/fuzz/moe/badge.png)](https://coveralls.io/r/fuzz/moe)

# Moe

A toolkit for using DynamoDB at scale

## Installation

Add this line to your application's Gemfile:

    gem "moe"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install moe

## Usage

### JRuby
Moe requires Ruby 2+ so you will need

```
export JRUBY_OPTS=--2.0`
```

to run it.

If you want to run the tests you will need to start fake_dynamo manually and

```
bundle exec rake rspec  # use rspec instead of spec to bypass auto fake_dynmo
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
