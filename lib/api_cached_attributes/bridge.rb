require_relative './lookup_service_attacher'

module ApiCachedAttributes
  # Our humble bridge
  module Bridge
    def api_cached_attributes(which_klass, options = {})
      options[:scope] = Array(options[:scope])
      klass = ApiCachedAttributes.get_attributes_class(which_klass)
      maker = LookupServiceAttacher.new(klass, options)
      maker.define_methods_on(self)
    end
  end
end
