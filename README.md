# RemoteResource

[![Build Status](https://travis-ci.org/mkcode/remote-resource.svg?branch=master)](https://travis-ci.org/mkcode/remote-resource)
[![Code Climate](https://codeclimate.com/github/mkcode/remote-resource/badges/gpa.svg)](https://codeclimate.com/github/mkcode/remote-resource)
[![Test Coverage](https://codeclimate.com/github/mkcode/remote-resource/badges/coverage.svg)](https://codeclimate.com/github/mkcode/remote-resource/coverage)
[![Inline docs](http://inch-ci.org/github/mkcode/remote_resource.svg?branch=master)](http://inch-ci.org/github/mkcode/remote_resource)

__RemoteResource__ allows you to easily create `ActiveRecord` style domain
objects that represent a foreign API. These `remote resources` can be mixed into
or associated with other ActiveRecord models in the same way you work with all
your other models. Using these conventions yields some major performance gains
through caching and fast and simple development through familiarity.

## Why RemoteResource

 * Familiar - The DSL used to wrap foreign APIs is simple and intuitive. Using
   the remote resource will be familiar to anyone who has worked with
   ActiveRecord models.

 * Reusable - Write your API interface once. Associate it with an ActiveRecord
   object, embed it into a value object, or instantiate it for use in a service.

 * Performant - API responses are transparently cached. Subsequent calls move at
   the speed of redis. Etag based cache expiring, which you may override. Makes
   detailed list pages possible.

 * Resiliant - Easy to configure error handling, just like ActionContoller. Use
   cached values to rescue momentary network failures.

## Getting started

Create a `remote_resource`, such as:

```ruby
# in app/remote_resources/github_user.rb
class GithubUser < RemoteResource::Base
  client { Octokit::Client.new }
  resource { |client, scope| client.user(scope[:github_login]) }

  attribute :id
  attribute :avatar_url

  ...
end
```

Associate it with your ActiveRecord `User` model:

```ruby
# in app/models/user.rb
class User < ActiveRecord::Base
  has_remote :github_user, scope: :github_login

  ...
end
```

And you now have an associated remote resource, that you can use just like you
local models.

```ruby
user = User.find(1)

user.github_user.id
user.github_user.avatar_url
```

Behind the scene, `has_remote` evaluated the `scope` on user 1 and issued a get
request to the GitHub API for the GithubUser with (local) User #1's
github_login. The response is cached and future github_user calls will be fast!

## Installation

Add this line to your application's Gemfile. __Please note the hyphen__

```ruby
gem 'remote-resource'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remote-resource

## Defining an RemoteResource

By convention, resource classes are located under app/remote_resources.
This folder is automatically added to your Rails eager loaded paths.

```ruby
# In `app/remote_resources/github_user.rb
class GithubUserAttributes < RemoteResource::Base
  client { Octokit::Client.new }

  resource { |client, scope| client.user(scope[:github_login]) }

  rescue_from Octokit::Unauthorized

  attribute :id
  attribute :avatar_url
  attribute :url
end
```

The are 4 class methods that are available to help define an (API) remote
resource. They are:

 * __client__: You return an instance of the web client that the API uses in a
   block. That block yields the scope. (More on scope later.)

 * __resource__: Supply a block to the resource method that returns a a remote
   resource. For example, the 'show user' response (GET /user/:github_login)
   that returns information about a specific user. The return value should
   respond to `to_hash` in order to be used with attribute. Optionally takes a
   symbol argument, specifying a name so that it may be looked up later.

 * __attribute__: A single piece of data from the resource (or web) response.
   This will be mapped to a method later. Optionally takes a second symbol
   argument referring to a non-default resource (with an argument).

 * __rescue_from__: Works in the same way that ActionController's rescue_from
   works. It takes one or many Error class(es), and either a block of a `:with`
   option that refers to an instance method on this class. The block or instance
   method receive the error and an additional context hash as arguments.

Remote resource allows you to define any instance method you like on it, which
may be used by being instantiated itself or from an associated model.

The following instance methods are available within a RemoteResource::Base class.

 * __client__ - returns the evaluated client block.

 * __resource(resource_name)__ - returns the evaluated resource block for the
   provided name. An optional argument returns the evaluated resource block with
   that name.

 * __with_error_handling__ - code executed within a block to this function will
   have this classes' error handling (from the rescue_from methods) enabled. It
   takes an optional options Hash which will be sent to error handling block or
   method which to allow for context specific behavior.

 * __the attributes__ - all of the attributes named in the class method are
   available as methods in the instance. Attribute methods always return
   strings.

```ruby
# In `app/remote_resources/github_user.rb
class GithubUserAttributes < RemoteResource::Base
  client { Octokit::Client.new }
  resource { |client, scope| client.user(scope[:github_login]) }
  attribute :name
  rescue_from Octokit::Unauthorized, with: :swallow_validate

  def markdown_summary
    with_error_handling action: :get_markdown do
      client.markdown "# A big hello to #{name}!!!"
    end
  end

  private

  def handle_fetch(exception, context)
    raise exception unless context[:action] == :validate
  end
end
```

In the above examples, the `markdown_summary` method returns a string containing
a small HTML fragment. The method body uses with evaluated client block which is
an Octokit client in this case. Before sending a string to be markdown-ified,
the `name` attribute is looked up. This is wrapped inside of a
`with_error_handling` block to catch any potential errors.

The private `handle_fetch` method above is a configured error handler, specified
on the above `rescue_from` call. In this case, it re-raises all Unauthorized
errors expect for when the action is :validate.

The above `markdown_summary` method may be used from an associated User as
follows. The `handle_fetch` method may not be used because it is private.

```ruby
user = User.find(1)
user.github_user.markdown_summary
```

## Instantiating Remote Resources directly

The above `GithubUser` example may also be instantiated on it's own. The
initializer takes the scope argument as an options Hash. In this case, because
in our resource block, we use `scope[:github_login]`, we send a `:github_login`
option into the constructor. For example:

```ruby
github_user = GithubUser.new(github_login: 'mkcode')
```

Now that we have an instance, we may call any of our custom defined methods on it.

```ruby
github_user.markdown_summary
#=> "<h1>A big hello to Chris Ewald!!!</h1>"
```

We also may call any of our defined attributes.

```ruby
github_user.name
#=> "Chris Ewald"
```

## The scope

The scope option evaluates the keys of the Hash on the object specifying it.
There are a few different ways to define the scope, but it is always sent into
the `client` and `resource` blocks as a symboled key / value Hash. Consider the
following lines evaluated inside a User model: `class User < ActiveRecord::Base`

 * `has_remote :github_user, scope: { id: :github_id }` - The scope is a Hash.
   The :github_id method will be called on the User and sent as the value of the
   :id key into the RemoteResource. Ex: `scope = { id: 234562 }`

 * `has_remote :github_user, scope: :github_id` - The scope is a single Symbol.
   Like above, the :github_id method will be called on User, except the value
   will be sent under a :github_id key. Ex: `scope = { github_id: 234562 }` This
   is just a shorthand for when the method on the calling object and the scope
   key are the same.

 * `has_remote :github_user, scope: [:github_id, :access_token]` - The scope is
   an Array. Both the :github_id and :access_token methods will be called on
   User and sent in under the same keys.
   Ex: `scope = { github_id: 234562, access_token: "af98f73qfh37ghf374h34rt9" }`

Once evaluated, scopes will remain frozen for the lifetime of a RemoteResource
instance. They are also used as piece of the cache_key.

## Is or has

Two methods are available for your model classes. `has_remote` and
`embeds_remote`. They take all the same options and do mostly the same thing;
create a method on the calling object, which returns that records associated
RemoteResource instance. `embeds_remote` will go one step further and define all
of the attribute getter methods on the calling class as well. This can be used
to create flat domain objects, or possibly value_objects, which are backed by
values from a remote API. This is largely related to Inhertance vs Composition
in programming theory which you are welcome to look up on your own time.
RemoteResource supports both styles; 'Is' through `embeds_remote` and 'has'
through `has_remote`. If unsure, it is best to prefer composition and use
`has_remote` over `embeds_remote` to create a clear distinction between your
local and remote domain.

## Extending other domain objects

If you do not use ActiveRecord in your app, you may still use remote-resource by
simply extending the Bridge module onto whatever class you use. The `has_remote`
and `embed_remote` methods will then be available. For example:

```ruby
class MyPoro
  extend RemoteResource::Bridge
  has_remote :github_user
end
```

## Configuration

In a initializer, like `config/initializers/remote_resource.rb`, you may
override the following options:

```ruby
# Setup global storages. For now there are Redis and Memory stores available.
# Default is Memory store.

require 'remote_resource/storage/redis'
RemoteResource.storages = [
  RemoteResource::Storage::Redis.new( Redis.new(url:nil) )
]

# Specify the logger RemoteResource should use:

RemoteResource.logger = Logger.new(STDOUT)

# Setup a lookup method. Only default for now, but the `validate` option
# may be changed to true or false. True will always revalidate. False will never
# revalidate. :cache_control respects the Cache-Control header.

require 'remote_resource/lookup/default'
RemoteResource.lookup_method = RemoteResource::Lookup::Default.new(validate: true)
```

## Notifications

There are 3 ActiveSupport notifications that you may subscribe to, to do in
depth profiling of this gem:

  * find.remote_resource
  * storage_lookup.remote_resource
  * http_get.remote_resource

```ruby
ActiveSupport::Notifications.subscribe('http_get.remote_resource') do |name, _start, _fin, _id, _payload|
  puts "HTTP_GET #{name}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/remote_resource. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
