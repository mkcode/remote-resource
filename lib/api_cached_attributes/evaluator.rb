module ApiCachedAttributes
  # Our humble lookup service
  class Evaluator
    attr_accessor :client_scope

    def initialize(base_class, options = {})
      @base_class = base_class
      @options = options
      @client_scope = {}
    end

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
