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

    def get
      @attribute.resource(@client)
      @client.last_response
    end

    def with_head_only_request(headers = {})
      head_method_partial_with_headers!(headers) if headers && headers.size > 0
      client_class = @client.singleton_class
      client_class.send(:alias_method, :orig_get, :get)
      client_class.send(:alias_method, :get, :head)
      yield @client
      client_class.send(:alias_method, :get, :orig_get)
    end

    def head_method_partial_with_headers!(headers)
      client_class = @client.singleton_class
      client_class.send(:alias_method, :orig_head, :head)
      client_class.send(:define_method, :head) do |url, _|
        orig_head(url, headers: headers)
      end
    end
  end
end
