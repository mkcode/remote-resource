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
  end
end
