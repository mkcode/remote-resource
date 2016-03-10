require 'api_cached_attributes/attribute_method_resolver'

module ApiCachedAttributes
  # non-anonymous namespace for our generated methods.
  class AttributeMethods < Module; end

  # Our humble lookup service attacher
  class AttributeMethodAttacher
    def initialize(base_class, options = {})
      @base_class = base_class
      @options = options
    end

    def attach_to(target_class)
      method_resolver = AttributeMethodResolver.new(@base_class, @options)

      target_class.instance_variable_set(method_resolver_var, method_resolver)
      target_class.send(:include, make_attribute_methods_module)
    end

    private

    def make_attribute_methods_module
      attribute_methods_module = AttributeMethods.new

      @base_class.attributes.keys.each do |method|
        attribute_methods_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}
            self.class.instance_variable_get(:#{method_resolver_var})
                      .get(:#{method}, self)
          end

          def #{method}=(other)
            fail ApiReadOnlyMethod.new('#{method}')
          end
        RUBY
      end
      attribute_methods_module
    end

    def method_resolver_var
      "@#{@base_class.underscore}_resolver".to_sym
    end
  end
end
