require 'api_cached_attributes/bridge'
require 'api_cached_attributes/dsl'
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

  # the base class for defining an api.
  class Base
    extend ApiCachedAttributes::DSL
    extend ActiveSupport::DescendantsTracker

    class << self
      def find_descendant(which_class)
        ensure_loaded(which_class)
        descendants.detect do |descendant|
          [descendant.underscore.to_sym, descendant.short_sym]
            .include? which_class.to_sym
        end
      end

      def ensure_loaded(which_class)
        which_class.to_s.camelize.concat('Attributes').safe_constantize ||
          which_class.to_s.camelize.safe_constantize
      end

      def underscore
        name.underscore
      end

      def short_name
        name.sub('Attributes', '')
      end

      def short_sym
        short_name.underscore.to_sym
      end
    end
  end
end
