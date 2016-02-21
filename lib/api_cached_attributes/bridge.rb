require_relative './method_maker'

module ApiCachedAttributes
  # Our humble bridge
  module Bridge
    def api_cached_attributes(which_klass, options = {})
      klass = ApiCachedAttributes.get_attributes_class(which_klass)
      maker = ApiCachedAttributes::MethodMaker.new(klass, options)
      maker.define_methods_on(self)
    end
  end
end
