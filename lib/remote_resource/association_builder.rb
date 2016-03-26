module RemoteResource
  # The AssociationBuilder class is responsible for defining a method(s) on a
  # target object that refers to an associated Base class. The body of that
  # method instantiates an attributes class.
  class AssociationBuilder
    attr_reader :base_class, :options

    def initialize(base_class, options = {})
      @base_class = base_class
      @options = ensure_options(options)
    end

    def associated_with(target_class)
      method_name = @options[:as]
      set_associated_class(method_name, target_class)
      define_association_method(method_name, target_class)
      self
    end

    private

    def remote_class_var(method)
      "@#{method}_remote_class".to_sym
    end

    def set_associated_class(method, target_class)
      target_class.instance_variable_set(remote_class_var(method), @base_class)
    end

    def define_association_method(method_name, target_class)
      scope = @options[:scope]
      scope = ":#{@options[:scope]}" if @options[:scope].is_a?(Symbol)
      target_class.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method_name}
          scope_evaluator = RemoteResource::ScopeEvaluator.new(#{scope})
          evaluated_scope = scope_evaluator.evaluate_on(self)
          self.class.instance_variable_get(:#{remote_class_var(method_name)})
                    .new(evaluated_scope)
        end
      RUBY
    end

    def ensure_options(options)
      options[:as] ||= @base_class.underscore
      options
    end
  end
end
