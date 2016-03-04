require 'api_cached_attributes/storage/serializers/marshal'
require 'api_cached_attributes/storage/storage_entry'

module ApiCachedAttributes
  module Storage
    class Redis
      def initialize(redis, serializer = nil)
        @redis = redis
        @serializer = serializer || Serializers::MarshalSerializer.new
      end

      def read_key(key)
        redis_value = @redis.hgetall key
        StorageEntry.new @serializer.load(redis_value['headers']),
                         @serializer.load(redis_value['data'])
      end

      def write_key(key, storage_entry)
        write_args = []
        storage_entry.to_hash.each_pair do |key, value|
          write_args.concat([key, @serializer.dump(value)]) unless value.empty?
        end
        @redis.hmset key, *write_args
      end
    end
  end
end
