module ApiCachedAttributes
  class DBCache
    ADAPTERS = %i(active_record)

    attr_reader :column_name
    attr_accessor :target_instance

    def initialize(adapter, column_name)
      @adapter = :active_record
      @column_name = column_name
    end

    def db_cache_value
      @target_instance.send(@column_name.to_sym)
    end

    def read(key)
    end

    def write(key, value)
    end
  end
end
