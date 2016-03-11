# ApiCachedAttributes

[![Build Status](https://travis-ci.org/mkcode/api_cached_attributes.svg?branch=master)](https://travis-ci.org/mkcode/api_cached_attributes)
[![Test Coverage](https://codeclimate.com/github/mkcode/api_cached_attributes/badges/coverage.svg)](https://codeclimate.com/github/mkcode/api_cached_attributes/coverage)
[![Inline docs](http://inch-ci.org/github/mkcode/api_cached_attributes.svg?branch=master)](http://inch-ci.org/github/mkcode/api_cached_attributes)

Cache your API. Add resiliency and speed to the APIs your app relies on.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_cached_attributes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_cached_attributes

## Usage

### Setup

In a initializer, like `config/initializers/api_cached_attributes.rb`

```ruby
# Setup global storages
require 'api_cached_attributes/storage/redis'

ApiCachedAttributes.storages = [
  ApiCachedAttributes::Storage::Redis.new( Redis.new(url:nil) )
]

# Setup lookup options.

lookup_method = AttributeLookup.new(
  validate: :cache_control,
  retry: 2,
  validate_failure: :storage_value_and_no_error
)

lookup_method.on_error do |error|
  Airbrake.notify(error)
end

ApiCachedAttributes.lookup = lookup_method
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_cached_attributes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

