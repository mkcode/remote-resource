module ApiAttrs
  class DBCache
    def initialize(klass, column: :api_attributes_cache)
      @adapter = :active_record # if klass.is_a? ActiveRecord::Base
      @column = column
    end

    def read(key: :default)
      klass.send(@column).send(key)
    end

    def write(value)
    end
  end
end
