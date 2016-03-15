require 'active_support/time'

require 'api_cached_attributes/storage/cache_control'

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
      {}.tap do |hash|
        hash[:data] = @data unless @data.size == 0
        hash[:headers] = @headers unless @headers.size == 0
      end
    end

    def cache_control
      @cache_control ||= CacheControl.new(headers['cache-control'])
    end

    # TODO: Extract this and make it better
    # See: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9.4
    # Cache-Control (http 1.1) overrides Expires header (http: 1.0)
    def expired?
      if cache_control.must_revalidate?
        true
      elsif cache_control.max_age
        expire = DateTime.parse(headers['date']) + cache_control.max_age.seconds
        Time.now > expire
      else
        false
      end
    end

    def data?
      !data.empty?
    end

    def exists?
      !headers.empty? || data?
    end

    def headers_for_validation
      v_headers = {}
      v_headers['If-None-Match'] = headers['etag'] if headers['etag']
      if headers['last-modified']
        v_headers['If-Modified-Since'] = headers['last-modified']
      end
      v_headers
    end

    def validateable?
      headers.key?('last-modified') || headers.key?('etag')
    end
  end
end
