require 'active_support/time'

require 'remote_resource/storage/cache_control'

module RemoteResource
  # An unset storage entry
  class NullStorageEntry
    attr_reader :headers, :data

    def initialize
      @headers = {}
      @data = {}
    end

    def to_hash
      { data: @data, headers: @headers }
    end

    def cache_control
      @cache_control ||= CacheControl.new('')
    end

    def expired?
      true
    end

    def data?
      false
    end

    def exists?
      false
    end

    def headers_for_validation
      {}
    end

    def validateable?
      false
    end
  end
end
