require 'api_cached_attributes/errors'
require 'api_cached_attributes/configuration/logger'
require 'api_cached_attributes/configuration/lookup_method'
require 'api_cached_attributes/configuration/storage'
require 'api_cached_attributes/version'
require 'api_cached_attributes/railtie' if defined?(::Rails)

require 'active_support/core_ext/string'
require 'active_support/descendants_tracker'
require 'active_support/dependencies/autoload'

# doc
module ApiCachedAttributes
  extend ActiveSupport::Autoload

  extend Configuration::Logger
  extend Configuration::Storage
  extend Configuration::LookupMethod

  autoload_under 'base' do
    autoload :Attributes
    autoload :Dsl
    autoload :BaseClassMethods
    autoload :Rescue
  end

  autoload :AssociationBuilder
  autoload :AttributeMethodAttacher
  autoload :AttributeSpecification
  autoload :Base
  autoload :Bridge
  autoload :LogSubscriber
  autoload :ScopeEvaluator
end
