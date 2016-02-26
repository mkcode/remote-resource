module ApiCachedAttributes
  # CacheClient currently only works for Octokit and Faraday::Base. The headers
  # and with_head_only_request methods may be overridden to create a CacheClient
  # that is able to override other http clients.
  class CacheClient
    def initialize(client)
      @client = client
    end

    def headers(block)
      with_head_only_request do |client|
        block.call(client)
      end
      @client.last_response.headers
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
