require 'active_support/core_ext/hash/reverse_merge'

require 'api_cached_attributes/attribute_storage_value'

module ApiCachedAttributes
  module Lookup
    # Default lookup class. Top most level class used for looking up attributes
    # across storages and remotely over http.
    #
    # Arguments:
    #   options:
    #     validate: 'cache_control', 'true', 'false' - Should values looked up
    #     in storage be validated with the server. The default value
    #     'cache_control', sets this according to the server returned
    #     Cache-Control header. Values true and false override this.
    class Default

      def initialize(options = {})
        @options = options.reverse_merge({
          validate: :cache_control
        })
      end

      def find(attribute)
        store_value = AttributeStorageValue.new(attribute)
        if store_value.data?
          if should_validate?(store_value)
            store_value.validate
          end
        else
          store_value.fetch
        end
        store_value
      end

      private

      def should_validate?(store_value)
        return @options[:validate] unless @options[:validate] == :cache_control
        store_value.validateable? && store_value.expired?
      end
    end
  end
end
