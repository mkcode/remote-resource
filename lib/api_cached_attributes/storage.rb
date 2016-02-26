module ApiCachedAttributes
  # Our humble storage
  module StorageRegistration
    def self.extended(klass)
      klass.instance_variable_set(:@storages, [])
    end

    def storages=(storages)
      @storages = storages
    end

    def storages
      @storages
    end
  end
end
