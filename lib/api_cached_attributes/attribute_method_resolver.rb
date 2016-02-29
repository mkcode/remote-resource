require_relative './cached_attribute'
require_relative './attribute_http_client'
require_relative './attribute_storage_lookup'
require_relative './storage/storage_entry'

module ApiCachedAttributes
  # Our humble lookup service
  class AttributeMethodResolver
    attr_reader :key_prefix, :attributes
    attr_accessor :db_cache

    def initialize(base_class, options)
      @base_class = base_class
      @options = options
      @db_cache = nil
      @attributes = create_cached_attributes!
    end

    def create_cached_attributes!
      @base_class.cached_attributes.map do |method, value|
        CachedAttribute.new(method, @base_class)
      end
    end

    def get_attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end

    def get_attribute_in_scope(name, scope)
      attr = get_attribute(name)
      attr.client_scope = scope
      attr
    end

    def get(method, scope, named_resource = :default, target_instance)
      attribute = get_attribute_in_scope(method, scope)

      store_attr = AttributeStorageLookup.new(attribute)
      attr_client = AttributeHttpClient.new(attribute)

      if store_attr.exists?
        new_headers = {
          "If-None-Match" => headers['etag'][2, 1000],
          "If-Modified-Since" => headers['last-modified']
        }
        header_response = attr_client.headers_only(new_headers)
        if header_response['status'] == '304 Not Modified'
          return store_attr.value
        end
      end

      store_attr.write(StorageEntry.from_response(attr_client.get))
      return store_attr.value
    end
  end
end
