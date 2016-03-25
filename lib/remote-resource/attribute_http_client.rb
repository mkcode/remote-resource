require 'remote_resource/notifications'

module RemoteResource
  class AttributeHttpClient
    include RemoteResource::Notifications

    def initialize(attribute, client = nil)
      @attribute = attribute
      @client = client || @attribute.client
      @resource_name = @attribute.resource_name
    end

    def get(headers = {})
      instrument_attribute('http_get', @attribute) do
        if headers && headers.size > 0
          with_headers_for_method(:get, headers) do |client|
            @attribute.resource(client)
          end
        else
          @attribute.resource(@client)
        end
      end
      @client.last_response
    end

    private

    # Internal: yield a client with headers bound on the supplied method.
    def with_headers_for_method(method, headers)
      old_method = "orig_#{method}".to_sym
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
