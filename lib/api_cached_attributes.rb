require 'api_cached_attributes/version'
require 'api_cached_attributes/db_cache'
require 'api_cached_attributes/dsl'
require 'api_cached_attributes/bridge'
require 'api_cached_attributes/subclass_registration'
require 'active_support/concern'
require 'active_support/core_ext/string'

# doc
module ApiCachedAttributes
  extend SubclassRegistration

  # the base class for defining an api.
  class Base
    extend ApiCachedAttributes::DSL

    def self.inherited(subclass)
      ApiCachedAttributes.register_attributes_class(subclass)
    end

    def self.underscore
      name.underscore
    end
  end
end