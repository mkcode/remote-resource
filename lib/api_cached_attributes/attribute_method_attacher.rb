require_relative './attribute_method_resolver'
require_relative './evaluator'
require_relative './db_cache_attacher'

module ApiCachedAttributes
  class ApiReadOnlyMethod < StandardError; end;

  # non-anonymous namespace for our generated methods.
  class AttributeMethods < Module; end

  # Our humble lookup service attacher
  class AttributeMethodAttacher
    def initialize(base_class, options)
      @base_class = base_class
      @options = options
    end

    def attach_to(target_class)
      method_resolver = AttributeMethodResolver.new(@base_class, @options)
      method_resolver.evaluator = Evaluator.new(@base_class, @options)
      db_cache_attacher = DBCacheAttacher.new(@base_class, @options)
      method_resolver.db_cache = db_cache_attacher.create_for_class target_class

      target_class.instance_variable_set(method_resolver_var, method_resolver)
      target_class.send(:include, make_attribute_methods_module(target_class))
    end

    def make_attribute_methods_module(target_class)
      attribute_methods_module = AttributeMethods.new

      @base_class.cached_attributes.each_pair do |method, value|
        attribute_methods_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}
            scope = {}
            %w(#{@options[:scope].join(', ')}).each do |scope_method|
              scope[scope_method.to_sym] = send(scope_method.to_sym)
            end
            self.class
                .instance_variable_get(:#{method_resolver_var.to_s})
                .get(:#{method}, scope, :#{value})
          end

          def #{method}=(other)
            msg = "`#{method}` was created by the `ApiCachedAttributes` gem, "
            msg += "which only supports API getters. Although, you "
            msg += "may override this method on `#{target_class.name}`."
            fail ApiCachedAttributes::ApiReadOnlyMethod.new(msg)
          end
        RUBY
      end
      attribute_methods_module
    end

    private

    def method_resolver_var
      "@#{@base_class.underscore}_resolver".to_sym
    end
  end
end
