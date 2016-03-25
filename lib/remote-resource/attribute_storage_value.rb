require 'active_support/core_ext/module/delegation'

require 'api_cached_attributes/attribute_http_client'
require 'api_cached_attributes/storage/storage_entry'
require 'api_cached_attributes/storage/null_storage_entry'
require 'api_cached_attributes/notifications'

module ApiCachedAttributes
  class AttributeStorageValue
    include ApiCachedAttributes::Notifications

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

    def fetch
      @attribute.with_error_handling action: :fetch do
        attr_client = AttributeHttpClient.new(@attribute)
        write(StorageEntry.from_response(attr_client.get))
      end
    end

    def validate
      @attribute.with_error_handling action: :validate do
        attr_client = AttributeHttpClient.new(@attribute)
        response = attr_client.get(headers_for_validation)
        write(StorageEntry.from_response(response))
        response.headers['status'] == '304 Not Modified'
      end
    end

    def write(storage_entry)
      @storage_entry = nil
      storages.each do |storage|
        storage.write_key(@attribute.key.for_storage, storage_entry)
      end
    end

    def storage_entry
      return @storage_entry if @storage_entry
      instrument_attribute('storage_lookup', @attribute) do
        storages.each do |storage|
          if (storage_entry = storage.read_key(@attribute.key.for_storage))
            return (@storage_entry = storage_entry)
          end
        end
        return (@storage_entry = NullStorageEntry.new)
      end
    end
  end
end
