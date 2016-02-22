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

    def response(name)
      if response = @base_class.responses[name]
        response.call(client)
      else
        fail ArgumentError.new("there is no response named #{name} on #{name}.")
      end
    end
  end
end
