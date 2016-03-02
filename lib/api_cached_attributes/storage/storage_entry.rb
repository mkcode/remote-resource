require_relative '../cache_control'

module ApiCachedAttributes
  # A storage entry closely resembles a network response. This seeks to
  # counteract the impedance mismatch because API responses are done on the
  # resource level and we want to query storages at the attribute level. Headers
  # are also handled on the resource (response) level as well, and thus apply
  # for many attributes.
  class StorageEntry
    def self.from_response(response)
      new(response.headers, response.data)
    end

    attr_reader :headers, :data

    def initialize(headers, data)
      @headers = headers.try(:to_hash) || {}
      @data = data.try(:to_hash) || {}
    end

    def to_hash
      {
        data: @data,
        headers: @headers
      }
    end

    def cache_control
      @cache_control ||= CacheControl.new(headers['cache-control'])
    end

    def exists?
      headers.size > 0
    end

    def validateable?
      headers.key?('last-modified') || headers.key?('etag')
    end

    def headers_for_validation
      v_headers = {}
      v_headers['If-None-Match'] = headers['etag'] if headers['etag']
      if headers['last-modified']
        v_headers['If-Modified-Since'] = headers['last-modified']
      end
      v_headers
    end
  end
end
