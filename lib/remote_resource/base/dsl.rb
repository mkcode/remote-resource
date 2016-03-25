module RemoteResource
  # Our humble DSL
  module Dsl
    attr_reader :client_proc, :resources

    def client(&block)
      @client_proc = block if block
    end

    def resource(name = :default, &block)
      if block
        @resources ||= {}
        @resources[name] = block
      else
        fail ArgumentError, 'must supply a block'
      end
    end

    def attribute(method, named_resource = :default)
      attributes[method] = named_resource
    end

    def attributes
      @attributes ||= {}
    end
  end
end
