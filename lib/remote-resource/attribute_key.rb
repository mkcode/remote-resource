module RemoteResource
  class AttributeKey
    attr_reader :prefix, :named_resource, :method

    def initialize(prefix, named_resource, scope, method)
      @prefix = prefix
      @named_resource = named_resource
      @scope = scope || {}
      @method = method
    end

    def scope_string
      @scope.map { |k, v| "#{k}=#{v}" }.join('&')
    end

    def for_resource
      [@prefix, scope_string, @named_resource].compact.join('/')
    end
    alias_method :for_storage, :for_resource

    def for_attribute
      [@prefix, scope_string, @named_resource, @method].compact.join('/')
    end
    alias_method :to_s, :for_attribute
  end
end
