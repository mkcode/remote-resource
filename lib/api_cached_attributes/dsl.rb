module ApiCachedAttributes
  # Our humble DSL
  module DSL
    attr_reader :client_proc, :resources, :cached_attributes

    def client(&block)
      if block
        @client_proc = block
      end
    end

    def named_resource(name, &block)
      if block
        @resources ||= {}
        @resources[name] = block
      else
        fail ArgumentError, "must supply a block"
      end
    end

    def default_resource(&block)
      named_resource(:default, &block)
    end

    def api_cached_attr(method, named_resource = :default)
      @cached_attributes ||= {}
      @cached_attributes[method] = named_resource
    end
  end
end
