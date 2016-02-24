module ApiCachedAttributes
  # Yes
  class CachedAttribute
    attr_reader :name, :resource_name

    def initialize(name, base_class)
      @name = name
      @base_class = base_class
    end
    alias_method :method, :name

    def client
      @base_class.client_proc.call(client_scope)
    end

    def resource(name)
      if resource = @base_class.resources[name]
        resource.call(client)
      else
        fail ArgumentError.new("there is no resource named #{name} on #{name}.")
      end
    end
  end
end
