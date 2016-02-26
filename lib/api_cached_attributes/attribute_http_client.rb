module ApiCachedAttributes
  class AttributeHttpClient
    def initialize(attribute, client = nil)
      @attribute = attribute
      @client = client || @attribute.client
      @resource_name = @attribute.resource_name
    end

    def headers_only
      with_head_only_request do |client|
        @attribute.resource(client)
      end
      @client.last_response.headers
    end

    def get
      @attribute.resource(@client)
      @client.last_response
    end

    def with_head_only_request
      client_class = @client.singleton_class
      client_class.send(:alias_method, :orig_get, :get)
      client_class.send(:alias_method, :get, :head)
      yield @client
      client_class.send(:alias_method, :get, :orig_get)
    end
  end
end
