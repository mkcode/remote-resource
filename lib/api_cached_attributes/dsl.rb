module ApiCachedAttributes
  # Our humble DSL
  module DSL
    attr_reader :client_proc, :responses, :cached_attributes

    def client(&block)
      if block
        @client_proc = block
      end
    end

    def named_response(name, &block)
      if block
        @responses ||= {}
        @responses[name] = block
      else
        fail ArgumentError, "must supply a block"
      end
    end

    def default_response(&block)
      named_response(:default, &block)
    end

    def api_cached_attr(method, named_response = :default)
      @cached_attributes ||= {}
      @cached_attributes[method] = named_response
    end
  end
end
