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
    def initialize(options = {})
      @options = options
    end

    def find(attribute)
      store_value = AttributeStorageValue.new(attribute)
      store_value.validate
      store_value
    end
  end
end
