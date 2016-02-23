require_relative './lookup_service_attacher'

module ApiCachedAttributes
  # Our humble bridge
  module Bridge
    def api_cached_attributes(which_klass, options = {})
      ensure_valid_options!(options)
      # Fetch the configuration base class for this api
      klass = ApiCachedAttributes.get_attributes_class(which_klass)
      # Configure the classes and methods and attach them here!
      attach_lookup_service!     klass, options
      attach_db_cache!           klass, options
    end

    private

    def ensure_valid_options!(options)
      options[:scope] = Array(options[:scope])
    end

    def attach_lookup_service!(klass, options)
      attacher = LookupServiceAttacher.new(klass, options)
      attacher.define_methods_on(self)
    end

    def attach_db_cache!(klass, options)
      attacher = DBCacheAttacher.new(klass, options)
      attacher.attach_to(self)
    end
  end
end
