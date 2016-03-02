require_relative './attribute_http_client'
require 'active_support/core_ext/module/delegation'

module ApiCachedAttributes
  class AttributeStorageValue
    delegate :data?, :exists?, :expired?, :headers_for_validation,
             :validateable?, to: :storage_entry

    def initialize(attribute)
      @attribute = attribute
      @storage_entry = nil
    end

    def value
      storage_entry.data[@attribute.name]
    end

    def storages
      ApiCachedAttributes.storages
    end

    def validate
      attr_client = AttributeHttpClient.new(@attribute)
      response = attr_client.get(headers_for_validation)
      write(StorageEntry.from_response(response))
      response.headers['status'] == '304 Not Modified'
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
