require 'api_cached_attributes/attribute_lookup'

module ApiCachedAttributes
  module Configuration
    # Our humble storage
    module LookupMethod
      def self.extended(klass)
        klass.instance_variable_set(:@lookup_method, nil)
      end

      def lookup_method=(lookup_method)
        @lookup_method = lookup_method
      end

      def lookup_method
        @lookup_method || default_lookup_method
      end

      def default_lookup_method
        Lookup::Default.new
      end
    end
  end
end
