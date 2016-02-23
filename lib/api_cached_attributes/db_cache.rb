module ApiCachedAttributes
  class DBCache
    ADAPTERS = %i(active_record)

    def initialize(adapter, column_name)
      @adapter = :active_record
      @column_name = column_name
    end

    def read(key: :default)
      klass.send(@column_name).send(key)
    end

    def write(value)
    end
  end
end
