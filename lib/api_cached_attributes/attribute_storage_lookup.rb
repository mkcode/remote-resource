module ApiCachedAttributes
  class AttributeStorageLookup
    def initialize(attribute)
      @attribute = attribute
    end

    def headers
      storage_entry.headers
    end

    def data
      storage_entry.data
    end

    def value
      storage_entry.data[@attribute.name]
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

    private

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
