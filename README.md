# ApiCachedAttributes

[![Build Status](https://travis-ci.org/mkcode/api_cached_attributes.svg?branch=master)](https://travis-ci.org/mkcode/api_cached_attributes)
[![Code Climate](https://codeclimate.com/github/mkcode/api_cached_attributes/badges/gpa.svg)](https://codeclimate.com/github/mkcode/api_cached_attributes)
[![Test Coverage](https://codeclimate.com/github/mkcode/api_cached_attributes/badges/coverage.svg)](https://codeclimate.com/github/mkcode/api_cached_attributes/coverage)
[![Inline docs](http://inch-ci.org/github/mkcode/api_cached_attributes.svg?branch=master)](http://inch-ci.org/github/mkcode/api_cached_attributes)

Cache your API. Add resiliency and speed to the APIs your app relies on.
Features:

 * A simple DSL for resource oriented APIs.
 * Create 'hybrid' (API and activerecord based) domain objects.
 * Major performance gains when API responses are served from (a redis) cache.
 * Don't fail when APIs your app relies on are momentarily down.
 * Respect your APIs Cache-Control header. Or don't. It's up to you.
 * Configurable logging and error reporting.
 * Trivial to add support for your new API client.
 * Multiple cache storage backends.

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

In a initializer, like `config/initializers/api_cached_attributes.rb`, you may override the following options:

```ruby
# Setup global storages. For now there is only redis and memory. Default is one
# Memory store.

require 'api_cached_attributes/storage/redis'
ApiCachedAttributes.storages = [
  ApiCachedAttributes::Storage::Redis.new( Redis.new(url:nil) )
]

# Setup a logger

ApiCachedAttributes.logger = Logger.new(STDOUT)

# Setup a lookup method. Only default for now, but the `cache_control` option
# may be changed to true or false. True will always revalidate. False will never
# revalidate. :cache_control respects the Cache-Control header.

require 'api_cached_attributes/lookup/default'
ApiCachedAttributes.lookup_method = ApiCachedAttributes::Lookup::Default.new(validate: true)
```

### Defining an API

By convention, api attribute classes are located under app/api_attributes and
always suffixed with _attributes. This folder is automatically added to your
Rails eager loaded paths.

In `app/api_attributes/github_user_attributes`:

```ruby
class GithubUserAttributes < ApiCachedAttributes::Base
  client { Octokit::Client.new }

  default_resource { |client, scope| client.user(scope[:github_login]) }

  attribute :id
  attribute :avatar_url
  attribute :url
  attribute :html_url
  attribute :type
  attribute :name
  attribute :company
  attribute :email
  attribute :public_repos
  attribute :updated_at
  attribute :created_at
end
```

The are 3 parts that every API definition class needs.

 * __client__: You return an instance of the web client that the API uses in a block. That block yields the scope. (More on scope later.)

 * __default_resource__: The resource that attributes with no second argument
   use. Roughly corresponds to a web request. The block is given the client
   (which was returned from the client block above) and the scope. It then
   issues a web request and returns a response. The response object must respond
   to the `to_hash` method.

 * __named_resource__: This is like the default resource except, the attribute's
   second argument refers to the named_resource for it to use.

 * __attribute__: A single piece of data from the resource (or web) response.
   This will be mapped to a method later. Optionally takes a second symbol
   argument referring to a non-default resource.


### Creating hybrid domain objects

In `app/models/github_user`:

```ruby
class GithubUser < ActiveRecord::Base
  validates :github_login, presence: true, uniqueness: true

  api_cached_attributes :github_user, scope: :github_login,
    attributes_map: { id: :github_id, updated_at: :github_updated_at,
                      created_at: :github_created_at }
end
```

We call __api_cached_attributes__ to include the previously defined attributes in the GithubUser model to create a hybrid domain object. This is partially backed by the database, and partially backed by the Github API.

We __scope: github_login__ option, collects the value of github_login on this model and sends this into the GithubUserAttributes class to make a unique client and resource. It does not need to be persisted (saved) to work.

The __attribues_map__ option, overrides the default method names on GithubUser. Because the model already has an id, updated_at, and created_at, we prefix the github api values with github. A `prefix` option is also available if all the defined methods shoudl be prefixed as well.

The __validates__ line is not needed, but helps. Trying to access the attributes without a github_login set, will cause an error. And in this table, conceptually, it makes sense for one record per user, which is why we validate uniqueness as well.

### Extending other domain object

If you do not use ActiveRecord in your app, you may still use api_cached_attributes by simply extending the Bridge module. Ex:

```ruby
class MyPoroDomainObject
  extend ApiCachedAttributes::Bridge # this includes the api_cached_attributes_method

  api_cached_attributes :github_user
end

```

### Notifications

There are 4 ActiveSupport notifications that you may subscribe to, to do in depth profiling of this gem:

  * find.api_cached_attributes
  * storage_lookup.api_cached_attributes
  * http_head.api_cached_attributes
  * http_get.api_cached_attributes

ActiveSupport::Notifications.subscribe('http_get.api_cached_attributes') do |name, _start, _fin, _id, _payload|
  puts "HTTP_GET #{name}"
end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/api_cached_attributes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

