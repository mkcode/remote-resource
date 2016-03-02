module ApiCachedAttributes
  # Our humble storage
  module LookupMethodRegistration
    def self.extended(klass)
      klass.instance_variable_set(:@lookup_method, [])
    end

    def lookup_method=(lookup_method)
      @lookup_method = lookup_method
    end

    def lookup_method
      @lookup_method
    end
  end
end
