require_relative './lookup_service'

module ApiCachedAttributes
  class ApiReadOnlyMethod < StandardError; end;

  # Our humble lookup service attacher
  class LookupServiceAttacher
    def initialize(base_class, options)
      @base_class = base_class
      @options = options
    end

    def define_methods_on(target_class)
      lookup_service = LookupService.new(@base_class, @options)
      lookup_service_method_name = "#{@base_class.underscore}_lookup"
      lookup_service_var = "@#{lookup_service_method_name}".to_sym
      target_class.instance_variable_set(lookup_service_var, lookup_service)

      @base_class.cached_attributes.each_pair do |method, value|
        target_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}
            scope = {}
            %w(#{@options[:scope].join(', ')}).each do |scope_method|
              scope[scope_method.to_sym] = send(scope_method.to_sym)
            end
            self.class
                .instance_variable_get(:#{lookup_service_var.to_s})
                .get(:#{method}, scope)
          end

          def #{method}=(other)
            msg = "`#{method}` was created by the `ApiCachedAttributes` gem, "
            msg += "which only supports API getters. Although, you "
            msg += "may override this method on `#{target_class.name}`."
            fail ApiCachedAttributes::ApiReadOnlyMethod.new(msg)
          end
        RUBY
      end
    end

  end
end
