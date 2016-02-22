module ApiCachedAttributes
  # Our humble lookup service
  class Evaluator
    def initialize(base_class)
      @base_class = base_class
      @client_scope = {}
    end

    def set_client_scope(hash)
      @client_scope = hash
    end

    def client
      @base_class.client_proc.call(@client_scope)
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
