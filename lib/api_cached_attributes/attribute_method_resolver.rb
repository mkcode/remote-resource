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

    def attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end

    def create_cached_attributes!
      @base_class.cached_attributes.map do |method, value|
        CachedAttribute.new(method, @base_class)
      end
    end

    def get(method, scope, named_resource = :default, target_instance)

      attr = attribute(method)
      attr.client_scope = scope


      store_attr = AttributeStorageLookup.new(attr)
      attr_client = AttributeHttpClient.new(attr)

      headers = store_attr.headers
      if headers.size > 0
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

    def key_prefix
      @base_class.underscore
    end

    def key_for(method, scope, named_resource = :default)
      scope_part = scope.map{ |k,v| "#{k}=#{v}" }.join('&')
      # "#{@key_prefix}/#{scope_part}/#{named_resource}/#{method}"
      [key_prefix, scope_part, named_resource, method].join('/')
    end
  end
end
