require_relative '../serializers/marshal'

module ApiCachedAttributes
  class DBCache
    ADAPTERS = %i(active_record)

    attr_reader :column_name
    attr_accessor :target_instance

    def initialize(adapter, column_name, serializer = :marshal)
      @adapter = :active_record
      @column_name = column_name.to_sym
      @serializer = Serializers::MarshalSerializer.new
    end

    # always returns a hash
    def read_column
      raw = @target_instance.read_attribute(column_name)
      raw ? @serializer.load(raw) : {}
    end

    def write_column(hash)
      fail ArgumentError 'must be a hash!' unless hash.is_a? Hash
      raw = @serializer.dump(hash)
      @target_instance.update_attribute(column_name, raw)
    end

    def read_key(key)
      read_column[key.to_sym]
    end

    def write_key(key, value)
      write_column(read_column.merge(key.to_sym => value))
    end
  end
end
