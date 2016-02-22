require_relative './lookup_service_attacher'

module ApiCachedAttributes
  # Our humble bridge
  module Bridge
    def api_cached_attributes(which_klass, options = {})
      options[:scope] = Array(options[:scope])
      klass = ApiCachedAttributes.get_attributes_class(which_klass)
      attacher = LookupServiceAttacher.new(klass, options)
      attacher.define_methods_on(self)
    end
  end
end
