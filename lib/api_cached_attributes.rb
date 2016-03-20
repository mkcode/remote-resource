require 'api_cached_attributes/base'
require 'api_cached_attributes/bridge'
require 'api_cached_attributes/errors'
require 'api_cached_attributes/configuration/logger'
require 'api_cached_attributes/configuration/lookup_method'
require 'api_cached_attributes/configuration/storage'
require 'api_cached_attributes/log_subscriber'
require 'api_cached_attributes/version'
require 'api_cached_attributes/railtie' if defined?(::Rails)

require 'active_support/core_ext/string'
require 'active_support/descendants_tracker'

# doc
module ApiCachedAttributes
  extend Configuration::Logger
  extend Configuration::Storage
  extend Configuration::LookupMethod
end
