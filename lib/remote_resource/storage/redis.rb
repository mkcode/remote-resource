require 'active_support/core_ext/hash/reverse_merge'

require 'remote_resource/storage/serializers/marshal_serializer'
require 'remote_resource/storage/storage_entry'

module RemoteResource
  module Storage
    class Redis
      def initialize(redis, options = {})
        @redis = redis
        @options = options.reverse_merge(
          serializer: Serializers::MarshalSerializer.new,
          expires_in: 1 * (60 * 60 * 24)
        )
        @serializer = @options[:serializer]
      end

      def read_key(key)
        redis_value = @redis.hgetall key
        StorageEntry.new @serializer.load(redis_value['headers']),
                         @serializer.load(redis_value['data'])
      end

      def write_key(storage_key, storage_entry)
        write_args = []
        storage_entry.to_hash.each_pair do |key, value|
          write_args.concat([key, @serializer.dump(value)]) unless value.empty?
        end
        @redis.multi do |multi|
          multi.hmset storage_key, *write_args
          multi.expire storage_key, @options[:expires_in]
        end
      end
    end
  end
end
