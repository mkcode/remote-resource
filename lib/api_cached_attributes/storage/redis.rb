require_relative '../storage'
require_relative './storage_entry'
require_relative './serializers/marshal'

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
        @redis.hmset key,
                     :headers, @serializer.dump(storage_entry.headers),
                     :data, @serializer.dump(storage_entry.data)
      end
    end
  end
end
