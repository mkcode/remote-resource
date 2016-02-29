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
      key = key_for(method, scope, named_resource)

      attr = attribute(method)
      attr.client_scope = scope

      # Phase 1: Get request from storage via the key
      #
      store_attr = AttributeStorageLookup.new(attr)
      headers = store_attr.headers
      # stored = store.lookup_attribute(attr)
      #   => This returns a new !!!! StorageEntry !!!!
      #      which has request_headers methods on it
      #
      # request_headers = stored.request_headers
      # headers = store_attr.headers

      # Phase 2: HEAD only request the HTTP endpoint (if we have cached data)
      #          Send etag headers so 304 NOT MODIFIED response is possible
      attr_client = AttributeHttpClient.new(attr)
      new_headers = {
        "If-None-Match" => headers['etag'][2, 1000],
        "If-Modified-Since" => headers['last-modified']
      }
      header_response = attr_client.headers_only(new_headers)
      response = attr_client.get

      storage_entry = StorageEntry.from_response(response)
      store_attr.write(storage_entry)

      # Phase 3: If 304 - then propagate value to all stores. (DB to redis)
      #          If 200 - GET request for data, then propagate to all stores.
      #          If error - Not sure (maybe read from cache?)
      #
      #          if response_headers.status == 304
      #            store.write_attribute(stored_attr)
      #            return stored
      #          else if response_headers.status == 200
      #            response = attr_client.get
      #            store.write_attribute(stored_attr)
      #            return stored
      #          else
      #            Error: What do we do for errors here???
      #          end
      #
      ##########################################################################
      #
      #                             END GOOD STUFF
      #
      ##########################################################################
      #
      # remote_attr = RemoteAttribute.new(attr)
      # if remote_attr

      # moc = MethodOverideClient.new( client )
      # response_headers = moc.headers_only( resources[:default] )
      # cache_resolver = ResponseCache.new( response_headers )

      # @evaluator.client_scope = scope
      # @db_cache.target_instance = target_instance

      # cache_client = CacheClient.new(@evaluator.client)
      # headers = cache_client.headers(@base_class.resources[:default])
      # cache_control = CacheControl.new(headers['cache-control'])

      # moc = MethodOverideClient.new( client )
      # response_headers = moc.headers_only( resources[:default] )
      # cache_resolver = ResponseCache.new( response_headers )
      #   => resources[:default]

      # AttributeLookupService

      unless false # cache_control.private?
        # return redis_value if @REDIS.read_key(key)
        db_value = @db_cache.read_key(key)
        if db_value
          puts 'DB HIT'
          return db_value
        end
        puts 'DB MISS'
      end

      # resource = @evaluator.resource(named_resource)
      value = resource.send(method.to_sym)
      @db_cache.write_key(key, value)
      value
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
