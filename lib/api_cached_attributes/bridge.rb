require_relative './lookup_service_attacher'
require_relative './db_cache_attacher'

module ApiCachedAttributes
  # Our humble bridge
  module Bridge
    # Setup the api cached attributes on this class.
    #
    # Behind the scenes, this is copying / and creating cache and api getter
    # methods to the class. Copies everything that is needed to begin using
    # these features.
    #
    # arguments:
    #
    #   - api_name: the api configuration class to include on this object.
    #               api_name is an underscored symbol type that has the last
    #               `Attributes` suffix dropped. Example:
    #                 (class) GithubUserAttributes => (symbol) :github_user
    #
    #   - options:  A hash of options. Keys are always symbols.
    #
    #     - scope:  methods set on this class for which the api is unique. May
    #               be a single symbol value or an array of symbols.
    #
    #     - cache_column: name of the column on this table to which the api
    #                     should persist its cache. Only required when the
    #                     default (magic) column name is not wanted.
    #
    # example:
    #
    #   class Repo < ActiveRecord::Base
    #     api_cached_attributes :github_repo, scope: [:login, :user]
    #
    #     ...
    #   end
    #
    #   The above `api_cache_attributes` call assumes that the following class
    #   exists:
    #
    #   class GithubRepoAttributes < ApiCachedAttributes::Base
    #     ...
    #   end
    #
    # returns nil
    def api_cached_attributes(which_klass, options = {})
      ensure_valid_options!(options)
      # Fetch the configuration base class for this api
      klass = ApiCachedAttributes.get_attributes_class(which_klass)
      # Configure the classes and methods and attach them here!
      attach_lookup_service!     klass, options
      attach_db_cache!           klass, options
    end

    private

    def ensure_valid_options!(options)
      options[:scope] = Array(options[:scope])
    end

    def attach_lookup_service!(klass, options)
      attacher = LookupServiceAttacher.new(klass, options)
      attacher.define_methods_on(self)
    end

    def attach_db_cache!(klass, options)
      attacher = DBCacheAttacher.new(klass, options)
      attacher.attach_to(self)
    end
  end
end
