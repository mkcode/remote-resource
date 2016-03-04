require_relative './attribute_storage_value'
require 'active_support/core_ext/hash/reverse_merge'
require 'api_cached_attributes/notifications'

module ApiCachedAttributes
  # Attribute lookup class. Top most level class used for looking up attributes
  # across storages and remotely over http.
  #
  # Arguments:
  #   options:
  #     validate: 'cache_control', 'true', 'false' - Should values looked up
  #     in storage be validated with the server. The default value
  #     'cache_control', sets this according to the server returned
  #     Cache-Control header. Values true and false override this.
  class AttributeLookup
    include ApiCachedAttributes::Notifications

    def initialize(options = {})
      @options = options.reverse_merge({
        validate: :cache_control
      })
    end

    def find(attribute)
      find_path = {}
      instrument_attribute('find', attribute, find_path: find_path) do
        store_value = AttributeStorageValue.new(attribute)
        if store_value.data?
          find_path[:exists?] = true
          if should_validate?(store_value)
            find_path[:should_validate?] = true
            store_value.validate
          else
            find_path[:should_validate?] = false
          end
        else
          find_path[:exists?] = false
          store_value.fetch
        end
        store_value
      end
    end

    private

    def should_validate?(store_value)
      return @options[:validate] unless @options[:validate] == :cache_control
      store_value.validateable? && store_value.expired?
    end
  end
end
