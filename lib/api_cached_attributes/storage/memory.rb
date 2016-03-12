require 'api_cached_attributes/storage/storage_entry'

module ApiCachedAttributes
  module Storage
    class Memory
      attr_accessor :memory_value

      def initialize
        @memory_value = {}
      end

      def read_key(key)
        value = @memory_value[key]
        return nil unless value.is_a? Hash
        StorageEntry.new(value['headers'], value['data'])
      end

      def write_key(key, storage_entry)
        @memory_value[key] = storage_entry.to_hash
      end
    end
  end
end
