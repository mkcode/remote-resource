require_relative './attribute_http_client'

module ApiCachedAttributes
  class AttributeStorageLookup
    def initialize(attribute)
      @attribute = attribute
    end

    def headers
      storage_entry.headers
    end

    def value
      storage_entry.data[@attribute.name]
    end

    def exists?
      storage_entry.headers.size > 0
    end

    def validateable?
      headers.key?('last-modified') || headers.key?('etag')
    end

    def validate
      attr_client = AttributeHttpClient.new(@attribute)
      response = attr_client.get(headers_for_validation)
      write(StorageEntry.from_response(response))
      response.headers['status'] == '304 Not Modified'
    end

    def headers_for_validation
      v_headers = {}
      v_headers['If-None-Match'] = headers['etag'] if headers['etag']
      if headers['last-modified']
        v_headers['If-Modified-Since'] = headers['last-modified']
      end
      v_headers
    end

    def storages
      ApiCachedAttributes.storages
    end

    def write(storage_entry)
      @storage_entry = nil
      storages.each do |storage|
        storage.write_key(@attribute.key.for_storage, storage_entry)
      end
    end

    def storage_entry
      return @storage_entry if @storage_entry
      storages.each do |storage|
        if storage_entry = storage.read_key(@attribute.key.for_storage)
          @storage_entry = storage_entry
          return @storage_entry
        end
      end
    end
  end
end
