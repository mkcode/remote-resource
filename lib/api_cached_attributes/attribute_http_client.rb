module ApiCachedAttributes
  class AttributeHttpClient
    def initialize(attribute, client = nil)
      @attribute = attribute
      @client = client || @attribute.client
      @resource_name = @attribute.resource_name
    end

    def headers_only(additional_headers = {})
      with_head_only_request(additional_headers) do |client|
        @attribute.resource(client)
      end
      @client.last_response.headers
    end

    def get(headers = {})
      if headers && headers.size > 0
        with_headers_for_method(:get, headers) do |client|
          @attribute.resource(client)
        end
      else
        @attribute.resource(@client)
      end
      @client.last_response
    end

    private

    # Internal: yield a client with the get method swapped for head.
    def with_head_only_request(headers = {})
      with_headers_for_method(:head, headers) do |client|
        client_class = client.singleton_class
        client_class.send(:alias_method, :orig_get, :get)
        client_class.send(:alias_method, :get, :head)
        yield client
        client_class.send(:alias_method, :get, :orig_get)
      end
    end

    # Internal: yield a client with headers bound on the supplied method.
    def with_headers_for_method(method, headers)
      old_method = "orig_#{method.to_s}".to_sym
      client_class = @client.singleton_class
      client_class.send(:alias_method, old_method, method)
      client_class.send(:define_method, method) do |url, _|
        send(old_method, url, headers: headers)
      end
      yield @client
      client_class.send(:alias_method, method, old_method)
      client_class.send(:remove_method, old_method)
    end
  end
end
