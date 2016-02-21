module ApiCachedAttributes
  # Our humble subclasses
  module SubclassRegistration
    def self.extended(klass)
      klass.instance_variable_set(:@subclasses, {})
    end

    def register_attributes_class(klass)
      name = klass.name
      ref_name = name.ends_with?('Attributes') ? name.slice(0...-10) : name
      @subclasses[ref_name.underscore.to_sym] = klass
    end

    def get_attributes_class(name)
      @subclasses[name.to_sym]
    end
  end
end
